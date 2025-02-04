import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'update_user_role_params.dart';

class UpdateUserRole implements Usecase<Result<User>, UpdateUserRoleParams> {
  final UserRepository _userRepository;

  UpdateUserRole({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(UpdateUserRoleParams params) async {
    try {
      // Validasi role executor
      if (params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya Super Admin yang dapat mengubah role user');
      }

      // Validasi role baru
      if (!User.isValidRole(params.newRole)) {
        return Result.failed(
            'Role ${params.newRole} tidak valid. Role yang tersedia: ${User.validRoles.join(", ")}');
      }

      // Tidak boleh mengubah role menjadi superAdmin
      if (params.newRole == 'superAdmin') {
        return const Result.failed(
            'Tidak dapat mengubah role user menjadi Super Admin');
      }

      // Get user yang akan diupdate
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(
            'Gagal mendapatkan data user: ${userResult.errorMessage}');
      }

      final user = userResult.resultValue!;

      // Validasi - tidak bisa mengubah role superAdmin
      if (user.role == 'superAdmin') {
        return Result.failed(
            'Tidak dapat mengubah role user ${user.name} karena memiliki role Super Admin');
      }

      // Validasi - tidak bisa mengubah ke role yang sama
      if (user.role == params.newRole) {
        return Result.failed(
            'User ${user.name} sudah memiliki role ${User.getRoleDisplayName(params.newRole)}');
      }

      // Update role user
      final updatedUser = user.copyWith(role: params.newRole);
      final updateResult = await _userRepository.updateUser(user: updatedUser);

      // Handle hasil update
      if (updateResult.isSuccess) {
        return Result.success(updateResult.resultValue!);
      } else {
        return Result.failed(
            'Gagal mengupdate role user: ${updateResult.errorMessage}');
      }
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
