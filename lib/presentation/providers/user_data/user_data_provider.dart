import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/usecase/authentication/login/login.dart';
import '../../../domain/usecase/authentication/register/register.dart';
import '../../../domain/usecase/authentication/upload_profile_picture/upload_profile_picture_params.dart';
import '../../../domain/usecase/user_management/activate_user/activate_user.dart';
import '../../../domain/usecase/user_management/deactivate_user/deactivate_user.dart';
import '../../../domain/usecase/user_management/update_user_role/update_user_role.dart';
import '../../utils/login_exception.dart';
import '../../utils/rate_limit_exception.dart';
import '../../utils/rate_limit_helper.dart';
import '../../utils/storage_helper.dart';
import '../usecases/authentication/get_logged_user_id_provider.dart';
import '../usecases/authentication/login_provider.dart';
import '../usecases/authentication/logout_provider.dart';
import '../usecases/authentication/register_provider.dart';
import '../usecases/authentication/upload_profile_picture_provider.dart';
import '../usecases/user_management/activate_user_provider.dart';
import '../usecases/user_management/deactivate_user_provider.dart';
import '../usecases/user_management/update_user_role_provider.dart';

part 'user_data_provider.g.dart';

@Riverpod(keepAlive: true)
class UserData extends _$UserData {
  final _streamController = StreamController<User?>.broadcast();
  late final RateLimitHelper _rateLimitHelper;

  Stream<User?> userStateStream() => _streamController.stream;

  @override
  Future<User?> build() async {
    try {
      _rateLimitHelper = RateLimitHelper();

      ref.onDispose(() {
        _streamController.close();
      });

      debugPrint('Initializing user data provider');
      final getLoggedUserId = ref.read(getLoggedUserIdProvider);
      var userResult = await getLoggedUserId(null);

      final user = switch (userResult) {
        Success(value: final user) => user,
        Failed(message: _) => null,
      };

      _notifyStateChange(user);
      return user;
    } catch (e) {
      debugPrint('Error initializing user data: $e');
      return null;
    }
  }

  void _notifyStateChange(User? user) {
    try {
      if (!_streamController.isClosed) {
        debugPrint('Notifying state change for user: ${user?.email}');
        _streamController.add(user);
      }
    } catch (e) {
      debugPrint('Error notifying state change: $e');
    }
  }

  // Method untuk login
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Check rate limiting
      if (_rateLimitHelper.isLimited) {
        final remaining = _rateLimitHelper.remainingLimitTime;
        throw RateLimitException(
            'Terlalu banyak percobaan login. Silakan coba lagi dalam ${remaining?.inMinutes} menit.');
      }

      // Set loading state
      state = const AsyncLoading();

      // Track attempt
      await _rateLimitHelper.incrementAttempt();

      // Basic validation
      if (email.trim().isEmpty || password.isEmpty) {
        throw const FormatException('Email dan password harus diisi');
      }

      final login = ref.read(loginProvider);
      var result = await login(LoginParams(
        email: email.trim(),
        password: password,
      ));

      // Handle result
      if (result.isSuccess && result.resultValue != null) {
        // Reset rate limit on success
        await _rateLimitHelper.reset();

        // Handle remember me
        if (rememberMe) {
          await StorageHelper.saveUserSession({
            'email': email.trim(),
            'password': password,
            'isLoggedIn': true,
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
        }

        // Update state and notify
        state = AsyncData(result.resultValue);
        _notifyStateChange(result.resultValue);
        debugPrint('Login successful for user: ${result.resultValue?.email}');
      } else {
        // Handle error case
        debugPrint('Login failed: ${result.errorMessage}');
        throw LoginException(result.errorMessage ?? 'Login gagal');
      }
    } on RateLimitException catch (e) {
      debugPrint('Rate limit exceeded: ${e.message}');
      state = AsyncError(FlutterError(e.message), StackTrace.current);
      _notifyStateChange(null);
      rethrow;
    } on LoginException catch (e) {
      debugPrint('Login error: ${e.message}');
      state = AsyncError(FlutterError(e.message), StackTrace.current);
      _notifyStateChange(null);
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      state = AsyncError(
          FlutterError(_formatErrorMessage(e.toString())), StackTrace.current);
      _notifyStateChange(null);
    }
  }

  String _formatErrorMessage(String error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network-request-failed')) {
      return 'Koneksi gagal. Periksa internet Anda.';
    }

    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Email atau password salah';
    }

    if (message.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
    }

    if (message.contains('invalid-email')) {
      return 'Format email tidak valid';
    }

    return 'Terjadi kesalahan. Silakan coba lagi';
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    String? photoUrl,
  }) async {
    try {
      state = const AsyncLoading();
      debugPrint('Starting registration for: ${email.trim()}');

      // Validasi input dasar
      if (!_validateRegistrationInput(
        email: email,
        password: password,
        name: name,
      )) {
        throw const FormatException(
            'Please fill in all required fields correctly');
      }

      final register = ref.read(registerProvider);
      var result = await register(RegisterParams(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phoneNumber: phoneNumber?.trim(),
        address: address?.trim(),
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl,
      ));

      if (result.isSuccess && result.resultValue != null) {
        debugPrint(
            'Registration successful for user: ${result.resultValue?.email}');
        state = AsyncData(result.resultValue);
        _notifyStateChange(result.resultValue);
        _resetRegistrationData();
      } else {
        debugPrint('Registration failed: ${result.errorMessage}');
        state = AsyncError(
            FlutterError(result.errorMessage ?? 'Registration failed'),
            StackTrace.current);
        _notifyStateChange(null);
      }
    } on FormatException catch (e) {
      debugPrint('Validation error: ${e.message}');
      state = AsyncError(FlutterError(e.message), StackTrace.current);
      _notifyStateChange(null);
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      state = AsyncError(
          FlutterError(_formatRegistrationError(e)), StackTrace.current);
      _notifyStateChange(null);
    }
  }

  bool _validateRegistrationInput({
    required String email,
    required String password,
    required String name,
  }) {
    if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
      debugPrint('Empty required field detected');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      debugPrint('Invalid email format: $email');
      return false;
    }

    if (password.length < 6) {
      debugPrint('Password too short');
      return false;
    }

    if (name.trim().length < 2) {
      debugPrint('Name too short');
      return false;
    }

    return true;
  }

  String _formatRegistrationError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('email-already-in-use')) {
      return 'Email sudah terdaftar';
    }

    if (message.contains('invalid-email')) {
      return 'Format email tidak valid';
    }

    if (message.contains('weak-password')) {
      return 'Password terlalu lemah';
    }

    if (message.contains('network')) {
      return 'Koneksi gagal. Periksa internet Anda';
    }

    return 'Terjadi kesalahan saat registrasi. Silakan coba lagi';
  }

  void _resetRegistrationData() {
    debugPrint('Resetting registration data');
    // Reset temporary registration data if needed
  }

  // Method untuk logout
  Future<void> logout() async {
    final logout = ref.read(logoutProvider);
    var result = await logout(null);

    switch (result) {
      case Success(value: _):
        // Jika sukses, set state ke null
        state = const AsyncData(null);
        _notifyStateChange(null);
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
        _notifyStateChange(state.valueOrNull);
    }
  }

  // Method untuk upload foto profil
  Future<void> uploadProfilePicture({
    required User user,
    required File imageFile,
  }) async {
    // Set state loading
    state = const AsyncLoading();

    // Ambil upload profile picture usecase dari provider
    final uploadProfilePicture = ref.read(uploadProfilePictureProvider);

    // Upload foto profil
    var result = await uploadProfilePicture(
      UploadProfilePictureParams(
        user: user,
        imageFile: imageFile,
      ),
    );

    // Handle hasil upload
    switch (result) {
      case Success(value: final updatedUser):
        // Jika sukses, update state dengan data user yang baru
        state = AsyncData(updatedUser);
        _notifyStateChange(updatedUser);
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
        _notifyStateChange(state.valueOrNull);
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String newRole,
  }) async {
    state = const AsyncLoading();

    final currentUser = state.valueOrNull;
    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      debugPrint('No current user found for role update');
      return;
    }

    // Validasi role baru
    if (!User.isValidRole(newRole)) {
      debugPrint('Invalid new role provided: $newRole');
      state =
          AsyncError(FlutterError('Invalid role value'), StackTrace.current);
      state = AsyncData(currentUser);
      _notifyStateChange(currentUser);
      return;
    }

    final updateRole = ref.read(updateUserRoleProvider);
    final result = await updateRole(UpdateUserRoleParams(
      uid: uid,
      newRole: newRole,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        debugPrint('Role successfully updated to: $newRole');
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        debugPrint('Failed to update role: $message');
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }

  Future<void> activateUser(String uid) async {
    state = const AsyncLoading();
    final currentUser = state.valueOrNull;

    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      return;
    }

    final activate = ref.read(activateUserProvider);
    final result = await activate(ActivateUserParams(
      uid: uid,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }

  Future<void> deactivateUser(String uid) async {
    state = const AsyncLoading();
    final currentUser = state.valueOrNull;

    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      return;
    }

    final deactivate = ref.read(deactivateUserProvider);
    final result = await deactivate(DeactivateUserParams(
      uid: uid,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }
}
