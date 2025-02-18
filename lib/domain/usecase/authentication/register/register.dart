import 'package:flutter/foundation.dart';
import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/user.dart';

part 'register_params.dart';

class Register implements Usecase<Result<User>, RegisterParams> {
  final Authentication _authentication;
  final UserRepository _userRepository;
  final ProgramRepository _programRepository;

  static const int maxAttempts = 3;
  static const Duration rateLimitDuration = Duration(minutes: 30);

  int _registrationAttempts = 0;
  DateTime? _lastRegistrationAttempt;

  Register({
    required Authentication authentication,
    required UserRepository userRepository,
    required ProgramRepository programRepository,
  })  : _authentication = authentication,
        _userRepository = userRepository,
        _programRepository = programRepository;

  @override
  Future<Result<User>> call(RegisterParams params) async {
    try {
      // Rate limiting check
      if (_isRateLimited()) {
        debugPrint('Registration rate limited');
        return const Result.failed(
            'Terlalu banyak percobaan registrasi. Silakan tunggu beberapa saat.');
      }

      _incrementAttempt();

      // Validate selected programs for santri
      if (params.role == 'santri') {
        final programResult =
            await _validateSelectedPrograms(params.selectedPrograms);
        if (programResult.isFailed) {
          debugPrint(
              'Program validation failed: ${programResult.errorMessage}');
          return Result.failed(programResult.errorMessage!);
        }
      }

      debugPrint('Starting registration for email: ${params.sanitizedEmail}');

      String uid = '';

      try {
        final authResult = await _authentication.register(
          email: params.sanitizedEmail,
          password: params.password,
          name: params.sanitizedName,
          role: params.role,
          selectedPrograms: params.selectedPrograms,
          photoUrl: params.photoUrl,
          phoneNumber: params.phoneNumber,
          address: params.address,
          dateOfBirth: params.dateOfBirth,
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
          role: params.role,
          selectedPrograms: params.selectedPrograms,
          photoUrl: params.photoUrl,
          phoneNumber: params.phoneNumber,
          address: params.address,
          dateOfBirth: params.dateOfBirth,
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

  Future<Result<void>> _validateSelectedPrograms(List<String> programs) async {
    try {
      // Check program existence and availability
      for (String programId in programs) {
        final program = await _programRepository.getProgramById(programId);
        if (program.isFailed) {
          return Result.failed('Program $programId tidak ditemukan');
        }
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failed('Error validating programs: ${e.toString()}');
    }
  }

  bool _isRateLimited() {
    if (_lastRegistrationAttempt == null) return false;

    if (_registrationAttempts >= maxAttempts) {
      final lockoutEndTime = _lastRegistrationAttempt!.add(rateLimitDuration);
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
