import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'firebase_user_repository.dart';

class FirebaseAuthentication implements Authentication {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseUserRepository _userRepository;

  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 30);
  static const int _maxRegistrationAttempts = 3;
  static const Duration _rateLimitDuration = Duration(minutes: 30);

  int _loginAttempts = 0;
  DateTime? _lastLoginAttempt;
  int _registrationAttempts = 0;
  DateTime? _lastRegistrationAttempt;

  FirebaseAuthentication({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    FirebaseUserRepository? userRepository,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        _userRepository = userRepository ?? FirebaseUserRepository();

  @override
  String? getLoggedUserId() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      // Verifikasi UID valid
      if (currentUser.uid.isEmpty) {
        debugPrint('Invalid UID found for authenticated user');
        return null;
      }

      debugPrint('Current user ID: ${currentUser.uid}');
      return currentUser.uid;
    } catch (e) {
      debugPrint('Error getting logged user ID: $e');
      return null;
    }
  }

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required List<String> selectedPrograms,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    try {
      // STEP 1: Input Validation
      final validationResult = await _validateRegistrationInput(
        email: email,
        password: password,
        name: name,
        role: role,
        selectedPrograms: selectedPrograms,
      );

      if (validationResult.isFailed) {
        debugPrint(
            'Registration validation failed: ${validationResult.errorMessage}');
        return Result.failed(validationResult.errorMessage!);
      }

      // STEP 2: Rate Limiting Check
      if (_isRateLimited()) {
        _incrementRegistrationAttempt();
        debugPrint('Registration rate limited');
        return const Result.failed(
          'Terlalu banyak percobaan registrasi. Silakan tunggu beberapa saat.',
        );
      }

      // STEP 3: Firebase Authentication Creation
      firebase_auth.UserCredential? authCredential;
      try {
        debugPrint('Creating Firebase Auth user for email: ${email.trim()}');
        authCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (authCredential.user == null) {
          throw Exception('Failed to create authentication user');
        }
      } catch (e) {
        final error = _handleAuthError(e);
        _incrementRegistrationAttempt();
        return Result.failed(error);
      }

      // STEP 4: Update Auth User Display Name
      try {
        await authCredential.user!.updateDisplayName(name.trim());
      } catch (e) {
        debugPrint('Warning: Failed to update display name: $e');
        // Continue as this is not critical
      }

      // STEP 5: Firestore User Creation
      try {
        final uid = authCredential.user!.uid;
        debugPrint('Creating Firestore user document for UID: $uid');

        final userResult = await _userRepository.createUser(
          uid: uid,
          email: email.trim(),
          name: name.trim(),
          role: role,
          photoUrl: photoUrl?.trim(),
          phoneNumber: phoneNumber?.trim(),
          address: address?.trim(),
          dateOfBirth: dateOfBirth,
          selectedPrograms: selectedPrograms,
        );

        if (userResult.isSuccess) {
          // STEP 6: Send Email Verification
          try {
            await authCredential.user!.sendEmailVerification();
            debugPrint('Verification email sent to: ${email.trim()}');
          } catch (e) {
            debugPrint('Warning: Failed to send verification email: $e');
            // Continue as this is not critical
          }

          _resetRegistrationAttempts();
          debugPrint('Successfully created user: $uid');
          return Result.success(uid);
        } else {
          // STEP 7: Rollback if Firestore creation fails
          await _cleanupFailedRegistration(authCredential.user);
          debugPrint(
              'Failed to create Firestore user: ${userResult.errorMessage}');
          return Result.failed(
              'Failed to create user profile: ${userResult.errorMessage}');
        }
      } catch (e) {
        // STEP 8: Cleanup on any error during Firestore creation
        await _cleanupFailedRegistration(authCredential.user);
        debugPrint('Error creating user profile: $e');
        return Result.failed(
            'Failed to complete registration: ${e.toString()}');
      }
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      return Result.failed('Registration failed: ${e.toString()}');
    }
  }

  // Validation helper
  Future<Result<void>> _validateRegistrationInput({
    required String email,
    required String password,
    required String name,
    required String role,
    required List<String> selectedPrograms,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return const Result.failed('Format email tidak valid');
      }

      if (!_isValidPassword(password)) {
        return const Result.failed('Password minimal 6 karakter');
      }

      if (name.trim().isEmpty) {
        return const Result.failed('Nama tidak boleh kosong');
      }

      if (!User.isValidRole(role)) {
        return const Result.failed('Role tidak valid');
      }

      if (role == 'santri' && selectedPrograms.isEmpty) {
        return const Result.failed('Santri harus memilih minimal 1 program');
      }

      // Check if email already exists
      try {
        final methods =
            await _firebaseAuth.fetchSignInMethodsForEmail(email.trim());
        if (methods.isNotEmpty) {
          return const Result.failed('Email sudah terdaftar');
        }
      } catch (e) {
        debugPrint('Error checking existing email: $e');
        // Continue if can't check (might be network error)
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failed('Validation error: ${e.toString()}');
    }
  }

  String _handleAuthError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'operation-not-allowed':
          return 'Registrasi dengan email/password tidak diizinkan';
        case 'weak-password':
          return 'Password terlalu lemah';
        default:
          return 'Gagal membuat akun: ${error.message}';
      }
    }
    return 'Terjadi kesalahan saat registrasi';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  // Rate limiting helpers
  bool _isRateLimited() {
    if (_lastRegistrationAttempt == null) return false;
    if (_registrationAttempts >= _maxRegistrationAttempts) {
      final lockoutEndTime = _lastRegistrationAttempt!.add(_rateLimitDuration);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      }
      _resetRegistrationAttempts();
    }
    return false;
  }

  void _incrementRegistrationAttempt() {
    _registrationAttempts++;
    _lastRegistrationAttempt = DateTime.now();
  }

  void _resetRegistrationAttempts() {
    _registrationAttempts = 0;
    _lastRegistrationAttempt = null;
  }

  Future<void> _cleanupFailedRegistration(firebase_auth.User? user) async {
    if (user != null) {
      try {
        await user.delete();
        debugPrint('Cleaned up Firebase Auth user after failed registration');
      } catch (e) {
        debugPrint('Error cleaning up failed registration: $e');
      }
      try {
        await _firebaseAuth.signOut();
      } catch (e) {
        debugPrint('Error signing out after cleanup: $e');
      }
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      if (_firebaseAuth.currentUser == null) {
        debugPrint('Logout successful');
        return const Result.success(null);
      } else {
        debugPrint('Logout failed: User still signed in');
        return const Result.failed('Failed to sign out');
      }
    } catch (e) {
      debugPrint('Unexpected error during logout: ${e.toString()}');
      return Result.failed('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<Result<String>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (_isLockedOut()) {
        debugPrint('Login attempt locked out');
        return const Result.failed(
            'Terlalu banyak percobaan login. Silakan tunggu beberapa saat.');
      }

      final normalizedEmail = email.trim().toLowerCase();

      if (!_isValidEmail(normalizedEmail)) {
        debugPrint('Invalid email format: $normalizedEmail');
        return const Result.failed('Format email tidak valid');
      }

      if (!_isValidPassword(password)) {
        debugPrint('Invalid password format');
        return const Result.failed('Password minimal 6 karakter');
      }

      _incrementLoginAttempt();
      debugPrint('Attempting login for email: $normalizedEmail');

      try {
        // Special handling untuk superadmin
        if (normalizedEmail == 'superadmin@sti.com') {
          final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );

          if (userCredential.user == null) {
            debugPrint('Superadmin login failed');
            return const Result.failed('Login gagal. Silakan coba lagi.');
          }

          final uid = userCredential.user!.uid;
          final userDoc =
              await _firebaseFirestore.collection('users').doc(uid).get();

          if (!userDoc.exists || userDoc.data()?['role'] != 'superAdmin') {
            debugPrint('Invalid superadmin credentials');
            await _firebaseAuth.signOut();
            return const Result.failed('Kredensial superadmin tidak valid');
          }

          _resetLoginAttempts();
          debugPrint('Superadmin login successful');
          return Result.success(uid);
        }

        // Regular user login
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        if (userCredential.user == null) {
          debugPrint('Login failed: No user returned');
          return const Result.failed('Login gagal. Silakan coba lagi.');
        }

        final uid = userCredential.user!.uid;
        final userDoc =
            await _firebaseFirestore.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          debugPrint('User document not found in Firestore');
          await _firebaseAuth.signOut();
          return const Result.failed(
              'Akun tidak ditemukan. Silakan hubungi admin.');
        }

        final userData = userDoc.data();
        if (userData == null || userData['isActive'] == false) {
          debugPrint('User account inactive or invalid');
          await _firebaseAuth.signOut();
          return const Result.failed(
              'Akun tidak aktif. Silakan hubungi admin.');
        }

        // Validasi role
        if (!User.isValidRole(userData['role'])) {
          debugPrint('Invalid role found');
          await _firebaseAuth.signOut();
          return const Result.failed('Terjadi kesalahan pada role akun');
        }

        _resetLoginAttempts();
        debugPrint('Login successful for UID: $uid');
        return Result.success(uid);
      } on firebase_auth.FirebaseAuthException catch (e) {
        debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
        return Result.failed(_getLoginErrorMessage(e.code));
      }
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      return const Result.failed('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  @override
  Future<Result<bool>> isSessionValid() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Result.success(false);
      }

      // Reload user untuk mendapatkan status terbaru
      await currentUser.reload();
      final idTokenResult = await currentUser.getIdTokenResult(true);

      // Cek expired token
      if (idTokenResult.expirationTime?.isBefore(DateTime.now()) ?? true) {
        return const Result.success(false);
      }

      // Cek status user di Firestore
      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || !(userDoc.data()?['isActive'] ?? false)) {
        return const Result.success(false);
      }

      return const Result.success(true);
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return const Result.failed('Failed to validate session');
    }
  }

  @override
  Future<Result<void>> refreshToken() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        return const Result.failed('No authenticated user');
      }

      try {
        // Force refresh token
        await currentUser.getIdToken(true);

        // Verifikasi ulang status user
        final userDoc = await _firebaseFirestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (!userDoc.exists || !(userDoc.data()?['isActive'] ?? false)) {
          // Jika user tidak aktif, force logout
          await _firebaseAuth.signOut();
          return const Result.failed('User is not active');
        }

        return const Result.success(null);
      } on firebase_auth.FirebaseAuthException catch (e) {
        debugPrint('Firebase Auth error refreshing token: ${e.message}');
        return Result.failed('Failed to refresh token: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return const Result.failed('Unexpected error refreshing token');
    }
  }

  String _getLoginErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  bool _isLockedOut() {
    if (_lastLoginAttempt == null) return false;
    if (_loginAttempts >= _maxLoginAttempts) {
      final lockoutEndTime = _lastLoginAttempt!.add(_lockoutDuration);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      }
      _resetLoginAttempts();
    }
    return false;
  }

  void _incrementLoginAttempt() {
    _loginAttempts++;
    _lastLoginAttempt = DateTime.now();
  }

  void _resetLoginAttempts() {
    _loginAttempts = 0;
    _lastLoginAttempt = null;
  }
}
