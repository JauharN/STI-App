// domain/usecase/authentication/reset_password/reset_password.dart
import '../../../../data/repositories/user_repository.dart';
import '../../../entities/result.dart';
import '../../usecase.dart';

class ResetPassword implements Usecase<Result<void>, String> {
  final UserRepository _userRepository;

  ResetPassword({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  @override
  Future<Result<void>> call(String email) async {
    try {
      if (email.isEmpty) {
        return const Result.failed('Email tidak boleh kosong');
      }

      // Validasi format email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return const Result.failed('Format email tidak valid');
      }

      // Kirim reset password email
      return _userRepository.resetPassword(email);
    } catch (e) {
      return Result.failed('Gagal mengirim reset password: ${e.toString()}');
    }
  }
}
