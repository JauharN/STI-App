import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'firebase_user_repository.dart';

class FirebaseAuthentication implements Authentication {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 30);
  static const int _maxRegistrationAttempts = 3;
  static const Duration _rateLimitDuration = Duration(minutes: 30);

  int _loginAttempts = 0;
  DateTime? _lastLoginAttempt;
  int _registrationAttempts = 0;
  DateTime? _lastRegistrationAttempt;

  FirebaseAuthentication({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  String? getLoggedUserId() => _firebaseAuth.currentUser?.uid;

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    String? photoUrl,
  }) async {
    try {
      // Validate input
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return const Result.failed('Invalid email format');
      }

      if (!_isValidPassword(password)) {
        debugPrint('Password validation failed');
        return const Result.failed('Password must be at least 6 characters');
      }

      // Validate role
      if (!User.isValidRole(role)) {
        debugPrint('Invalid role provided: $role');
        return const Result.failed('Invalid role value');
      }

      // Check rate limiting
      if (_isRegistrationLimited()) {
        _incrementRegistrationAttempts();
        debugPrint('Registration rate limited');
        return const Result.failed(
            'Too many registration attempts. Please try again later.');
      }

      debugPrint(
          'Starting Firebase Auth registration for email: ${email.trim()}');

      var userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint('Firebase Auth registration successful for UID: $uid');

      // Save to Firestore with all data
      final userRepo = FirebaseUserRepository();
      final result = await userRepo.createUser(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        phoneNumber: phoneNumber?.trim(),
        address: address?.trim(),
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl?.trim(),
      );

      if (result.isSuccess) {
        _resetRegistrationAttempts();
        debugPrint('User data saved successfully for UID: $uid');
        return Result.success(uid);
      } else {
        debugPrint('Failed to save user data: ${result.errorMessage}');
        await _cleanupFailedRegistration(userCredential.user);
        return Result.failed(
            'Failed to save user data: ${result.errorMessage}');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _incrementRegistrationAttempts();
      debugPrint('Firebase Auth registration failed: ${e.message}');
      return Result.failed(_getRegistrationErrorMessage(e.code));
    } catch (e) {
      _incrementRegistrationAttempts();
      debugPrint('Unexpected error during registration: $e');
      return Result.failed('Registration failed: ${e.toString()}');
    }
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

  String _getRegistrationErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email format';
      case 'operation-not-allowed':
        return 'Email/password registration is not enabled';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Registration failed';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  bool _isRegistrationLimited() {
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

  void _incrementRegistrationAttempts() {
    _registrationAttempts++;
    _lastRegistrationAttempt = DateTime.now();
  }

  void _resetRegistrationAttempts() {
    _registrationAttempts = 0;
    _lastRegistrationAttempt = null;
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

      // Normalize email dan validasi input
      final normalizedEmail = email.trim().toLowerCase();
      if (!_isValidEmail(normalizedEmail)) {
        debugPrint('Invalid email format: $normalizedEmail');
        return const Result.failed('Format email tidak valid');
      }

      if (!_isValidPassword(password)) {
        debugPrint('Invalid password format');
        return const Result.failed('Password minimal 6 karakter');
      }

      // Increment attempt sebelum mencoba
      _incrementLoginAttempt();

      debugPrint('Attempting login for email: $normalizedEmail');

      try {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        if (userCredential.user == null) {
          debugPrint('Login failed: No user returned');
          return const Result.failed('Login gagal. Silakan coba lagi.');
        }

        final uid = userCredential.user!.uid;

        // Verify user di Firestore
        final db = FirebaseFirestore.instance;
        final userDoc = await db.collection('users').doc(uid).get();

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

        _resetLoginAttempts(); // Reset hanya setelah login sukses

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
