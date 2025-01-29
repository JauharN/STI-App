import 'package:flutter/foundation.dart';
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
    // Validasi role pengguna yang melakukan perubahan
    if (params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed('Only Super Admin can change roles');
    }

    // Validasi role baru
    if (!UserRole.values.contains(params.newRole)) {
      return const Result.failed('Invalid role provided');
    }

    // Tidak boleh mengubah role menjadi Super Admin
    if (params.newRole == UserRole.superAdmin) {
      return const Result.failed('Cannot assign Super Admin role');
    }

    // Ambil data pengguna yang akan diubah
    final userResult = await _userRepository.getUser(uid: params.uid);
    if (userResult.isFailed) return userResult;

    final currentUser = userResult.resultValue!;

    // Tidak boleh mengubah role pengguna dengan role Super Admin
    if (currentUser.role == UserRole.superAdmin) {
      return const Result.failed('Cannot modify Super Admin role');
    }

    // Lakukan pembaruan role
    final updatedUser = currentUser.copyWith(role: params.newRole);
    final updateResult = await _userRepository.updateUser(user: updatedUser);

    if (updateResult.isSuccess) {
      // Log perubahan role
      if (kDebugMode) {
        print(
            'Role updated successfully: ${currentUser.uid} -> ${updatedUser.role}');
      }
    }

    return updateResult;
  }
}
