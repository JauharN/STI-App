import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

// Parameter class untuk UpdateUserRole usecase
class UpdateUserRoleParams {
  final String uid;
  final UserRole newRole;
  final UserRole currentUserRole; // Role dari user yang melakukan update

  UpdateUserRoleParams({
    required this.uid,
    required this.newRole,
    required this.currentUserRole,
  });
}

class UpdateUserRole implements Usecase<Result<User>, UpdateUserRoleParams> {
  final UserRepository _userRepository;

  UpdateUserRole({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(UpdateUserRoleParams params) async {
    try {
      // Validasi hak akses
      if (params.currentUserRole != UserRole.superAdmin) {
        return const Result.failed(
            'Hanya Super Admin yang dapat mengubah role');
      }

      // Validasi role yang akan diubah
      if (params.newRole == UserRole.superAdmin) {
        return const Result.failed(
            'Tidak dapat membuat user menjadi Super Admin');
      }

      // Dapatkan user yang akan diupdate
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(userResult.errorMessage!);
      }

      final user = userResult.resultValue!;

      // Update role user
      final updatedUser = user.copyWith(role: params.newRole);

      return await _userRepository.updateUser(user: updatedUser);
    } catch (e) {
      return Result.failed('Gagal mengupdate role: ${e.toString()}');
    }
  }
}
