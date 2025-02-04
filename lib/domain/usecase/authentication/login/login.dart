import 'package:flutter/foundation.dart';
import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import '../../../entities/result.dart';
import '../../../entities/user.dart';

part 'login_params.dart';

class Login implements Usecase<Result<User>, LoginParams> {
  final Authentication authentication;
  final UserRepository userRepository;

  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  int _attempts = 0;
  DateTime? _lastAttempt;

  Login({required this.authentication, required this.userRepository});

  @override
  Future<Result<User>> call(LoginParams params) async {
    try {
      // Rate limiting check
      if (_isLocked()) {
        debugPrint('Login locked due to too many attempts');
        return const Result.failed(
            'Terlalu banyak percobaan, silakan tunggu beberapa saat');
      }

      _incrementAttempt();

      // Validate input dengan regex yang lebih ketat
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(params.email.trim())) {
        debugPrint('Invalid email format: ${params.email}');
        return const Result.failed('Format email tidak valid');
      }

      if (params.password.length < 6) {
        debugPrint('Password too short');
        return const Result.failed('Password minimal 6 karakter');
      }

      debugPrint('Attempting login for email: ${params.email}');

      var loginResult = await authentication.login(
        email: params.email.trim().toLowerCase(),
        password: params.password,
      );

      if (loginResult.isSuccess) {
        debugPrint('Authentication successful, fetching user data');

        var userResult =
            await userRepository.getUser(uid: loginResult.resultValue!);

        if (userResult.isSuccess) {
          final user = userResult.resultValue!;

          if (!user.isActive) {
            debugPrint('Login failed: User account is inactive');
            return const Result.failed(
                'Akun tidak aktif, silakan hubungi admin');
          }

          // Validasi role
          if (!User.isValidRole(user.role)) {
            debugPrint('Login failed: Invalid role found');
            return const Result.failed('Terjadi kesalahan pada role akun');
          }

          debugPrint('Role from Firestore: ${user.role}');

          _resetAttempts(); // Reset setelah login berhasil

          debugPrint('Login successful for user: ${user.name}');
          return Result.success(user);
        } else {
          debugPrint('Failed to fetch user data: ${userResult.errorMessage}');
          return Result.failed(
              'Gagal mengambil data user: ${userResult.errorMessage}');
        }
      } else {
        debugPrint('Authentication failed: ${loginResult.errorMessage}');
        return Result.failed(loginResult.errorMessage ?? 'Login gagal');
      }
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      return const Result.failed('Terjadi kesalahan, silakan coba lagi');
    }
  }

  bool _isLocked() {
    if (_lastAttempt == null) return false;
    if (_attempts >= maxAttempts) {
      if (DateTime.now().difference(_lastAttempt!) < lockoutDuration) {
        return true;
      }
      _resetAttempts();
    }
    return false;
  }

  void _incrementAttempt() {
    _attempts++;
    _lastAttempt = DateTime.now();
  }

  void _resetAttempts() {
    _attempts = 0;
    _lastAttempt = null;
  }
}
