import 'package:flutter/foundation.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../entities/result.dart';
import '../../usecase.dart';

class ResetPassword implements Usecase<Result<void>, String> {
  final UserRepository _userRepository;
  static const int _maxAttempts = 3;
  static const Duration _limitDuration = Duration(minutes: 30);
  int _attempts = 0;
  DateTime? _lastAttempt;

  ResetPassword({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<void>> call(String email) async {
    try {
      if (_isRateLimited()) {
        return const Result.failed('Too many attempts. Try again later.');
      }

      if (!_isValidEmail(email)) {
        return const Result.failed('Invalid email format');
      }

      _incrementAttempt();

      final result = await _userRepository.resetPassword(email);

      if (result.isSuccess) {
        debugPrint('Password reset email sent successfully');
        _resetAttempts();
      } else {
        debugPrint('Failed to send reset email: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error in reset password: $e');
      return Result.failed('Failed to send reset password email: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());
  }

  bool _isRateLimited() {
    if (_lastAttempt == null) return false;
    if (_attempts >= _maxAttempts) {
      final limitEnd = _lastAttempt!.add(_limitDuration);
      if (DateTime.now().isBefore(limitEnd)) return true;
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
