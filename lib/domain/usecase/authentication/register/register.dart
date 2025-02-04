import 'package:flutter/foundation.dart';
import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import '../../../entities/result.dart';
import '../../../entities/user.dart';

part 'register_params.dart';

class Register implements Usecase<Result<User>, RegisterParams> {
  final Authentication _authentication;
  final UserRepository _userRepository;

  // Rate limiting improvements
  static const int _maxRegistrationAttempts = 3;
  static const Duration _rateLimitDuration = Duration(minutes: 30);
  int _registrationAttempts = 0;
  DateTime? _lastRegistrationAttempt;

  Register({
    required Authentication authentication,
    required UserRepository userRepository,
  })  : _authentication = authentication,
        _userRepository = userRepository;

  @override
  Future<Result<User>> call(RegisterParams params) async {
    try {
      // Rate limiting check
      if (_isRateLimited()) {
        return const Result.failed(
            'Too many registration attempts. Please try again later.');
      }

      _incrementAttempt();

      debugPrint('Starting registration for email: ${params.sanitizedEmail}');

      String uid = '';
      try {
        final authResult = await _authentication.register(
          email: params.sanitizedEmail,
          password: params.password,
          name: params.sanitizedName,
          role: params.role, // Now passing string role
        );

        if (authResult.isFailed) {
          debugPrint(
              'Authentication registration failed: ${authResult.errorMessage}');
          return Result.failed(authResult.errorMessage!);
        }

        uid = authResult.resultValue!;
        debugPrint('Authentication registration successful for UID: $uid');
      } catch (e) {
        debugPrint('Error during authentication registration: $e');
        return Result.failed('Registration failed: ${e.toString()}');
      }

      try {
        final userResult = await _userRepository.createUser(
          uid: uid,
          email: params.sanitizedEmail,
          name: params.sanitizedName,
          photoUrl: params.photoUrl,
          phoneNumber: params.sanitizedPhoneNumber,
          address: params.sanitizedAddress,
          dateOfBirth: params.dateOfBirth,
          role: params.role, // Now passing string role
        );

        if (userResult.isSuccess) {
          debugPrint('User data saved successfully for UID: $uid');
          _resetAttempts();
          return Result.success(userResult.resultValue!);
        } else {
          debugPrint('Failed to save user data: ${userResult.errorMessage}');
          await _handleFailedRegistration(uid);
          return Result.failed(
              'Failed to complete registration: ${userResult.errorMessage}');
        }
      } catch (e) {
        debugPrint('Error saving user data: $e');
        await _handleFailedRegistration(uid);
        return Result.failed('Failed to save user data: ${e.toString()}');
      }
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      return Result.failed('Registration failed: ${e.toString()}');
    }
  }

  bool _isRateLimited() {
    if (_lastRegistrationAttempt == null) return false;
    if (_registrationAttempts >= _maxRegistrationAttempts) {
      final lockoutEndTime = _lastRegistrationAttempt!.add(_rateLimitDuration);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      }
      _resetAttempts();
    }
    return false;
  }

  void _incrementAttempt() {
    _registrationAttempts++;
    _lastRegistrationAttempt = DateTime.now();
  }

  void _resetAttempts() {
    _registrationAttempts = 0;
    _lastRegistrationAttempt = null;
  }

  Future<void> _handleFailedRegistration(String uid) async {
    try {
      await _authentication.logout();
      debugPrint('Cleaned up failed registration for UID: $uid');
    } catch (e) {
      debugPrint('Error cleaning up failed registration: $e');
    }
  }
}
