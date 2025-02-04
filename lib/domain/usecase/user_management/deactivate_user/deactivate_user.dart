import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'deactivate_user_params.dart';

class DeactivateUser implements Usecase<Result<User>, DeactivateUserParams> {
  final UserRepository _userRepository;

  DeactivateUser({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(DeactivateUserParams params) async {
    try {
      // Validasi role user yang melakukan deaktivasi
      if (params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya Super Admin yang dapat menonaktifkan user');
      }

      // Dapatkan user yang akan dinonaktifkan
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(
            'Gagal mendapatkan data user: ${userResult.errorMessage}');
      }

      final user = userResult.resultValue!;

      // Validasi - tidak bisa menonaktifkan Super Admin
      if (user.role == 'superAdmin') {
        return const Result.failed(
            'Tidak dapat menonaktifkan user dengan role Super Admin');
      }

      // Cek apakah user sudah nonaktif
      if (!user.isActive) {
        return Result.failed('User ${user.name} sudah dalam keadaan nonaktif');
      }

      // Nonaktifkan user
      final updatedUser = user.copyWith(isActive: false);
      final updateResult = await _userRepository.updateUser(user: updatedUser);

      // Handle hasil update
      if (updateResult.isSuccess) {
        return Result.success(updateResult.resultValue!);
      } else {
        return Result.failed(
            'Gagal menonaktifkan user: ${updateResult.errorMessage}');
      }
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
