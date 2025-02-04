import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'get_users_by_role_params.dart';

class GetUsersByRole
    implements Usecase<Result<List<User>>, GetUsersByRoleParams> {
  final UserRepository _userRepository;

  GetUsersByRole({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<List<User>>> call(GetUsersByRoleParams params) async {
    try {
      // Validasi role yang request
      if (params.currentUserRole == 'santri') {
        return const Result.failed('Santri tidak dapat mengakses daftar user');
      }

      // Validasi akses berdasarkan role
      if (!_canAccessRole(params.currentUserRole, params.roleToGet)) {
        return Result.failed(
            'User dengan role ${User.getRoleDisplayName(params.currentUserRole)} '
            'tidak dapat mengakses daftar ${User.getRoleDisplayName(params.roleToGet)}');
      }

      // Validasi role yang diminta valid
      if (!User.isValidRole(params.roleToGet)) {
        return const Result.failed('Role yang diminta tidak valid');
      }

      // Get users dari repository
      final result =
          await _userRepository.getUsersByRole(role: params.roleToGet);

      if (result.isFailed) {
        return Result.failed(
            'Gagal mendapatkan daftar user: ${result.errorMessage}');
      }

      // Filter berdasarkan status aktif jika diperlukan
      final users = result.resultValue!;
      final filteredUsers = params.includeInactive
          ? users
          : users.where((user) => user.isActive).toList();

      return Result.success(filteredUsers);
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }

  bool _canAccessRole(String currentRole, String roleToAccess) {
    switch (currentRole) {
      case 'superAdmin':
        return true; // Super Admin dapat mengakses semua role
      case 'admin':
        // Admin hanya bisa melihat admin dan santri, tidak bisa lihat superAdmin
        return roleToAccess != 'superAdmin';
      default:
        return false;
    }
  }
}
