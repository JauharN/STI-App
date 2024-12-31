import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

// Parameter class untuk DeactivateUser usecase
class DeactivateUserParams {
  final String uid;
  final UserRole currentUserRole; // Role dari user yang melakukan deaktivasi

  DeactivateUserParams({
    required this.uid,
    required this.currentUserRole,
  });
}

class DeactivateUser implements Usecase<Result<User>, DeactivateUserParams> {
  final UserRepository _userRepository;

  DeactivateUser({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(DeactivateUserParams params) async {
    try {
      // Validasi hak akses
      if (params.currentUserRole != UserRole.superAdmin) {
        return const Result.failed(
            'Hanya Super Admin yang dapat menonaktifkan user');
      }

      // Dapatkan user yang akan dinonaktifkan
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(userResult.errorMessage!);
      }

      final user = userResult.resultValue!;

      // Validasi - tidak bisa menonaktifkan Super Admin
      if (user.role == UserRole.superAdmin) {
        return const Result.failed('Tidak dapat menonaktifkan Super Admin');
      }

      // Jika user sudah nonaktif
      if (!user.isActive) {
        return const Result.failed('User sudah dalam keadaan nonaktif');
      }

      // Nonaktifkan user
      final updatedUser = user.copyWith(isActive: false);

      return await _userRepository.updateUser(user: updatedUser);
    } catch (e) {
      return Result.failed('Gagal menonaktifkan user: ${e.toString()}');
    }
  }
}
