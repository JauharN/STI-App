import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

// Parameter class untuk GetUsersByRole usecase
class GetUsersByRoleParams {
  final UserRole roleToGet;
  final UserRole currentUserRole; // Role dari user yang melakukan request
  final bool includeInactive; // Option untuk include/exclude user nonaktif

  GetUsersByRoleParams({
    required this.roleToGet,
    required this.currentUserRole,
    this.includeInactive = false,
  });
}

class GetUsersByRole
    implements Usecase<Result<List<User>>, GetUsersByRoleParams> {
  final UserRepository _userRepository;

  GetUsersByRole({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<List<User>>> call(GetUsersByRoleParams params) async {
    try {
      // Validasi hak akses
      if (params.currentUserRole == UserRole.santri) {
        return const Result.failed(
            'Santri tidak memiliki akses ke daftar user');
      }

      if (params.currentUserRole == UserRole.admin &&
          params.roleToGet == UserRole.superAdmin) {
        return const Result.failed(
            'Admin tidak dapat melihat daftar Super Admin');
      }

      // Get users by role
      final usersResult =
          await _userRepository.getUsersByRole(role: params.roleToGet);

      if (usersResult.isFailed) {
        return Result.failed(usersResult.errorMessage!);
      }

      var users = usersResult.resultValue!;

      // Filter berdasarkan status aktif jika diperlukan
      if (!params.includeInactive) {
        users = users.where((user) => user.isActive).toList();
      }

      return Result.success(users);
    } catch (e) {
      return Result.failed('Gagal mendapatkan daftar user: ${e.toString()}');
    }
  }
}
