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
    // Validasi role pengguna
    if (params.currentUserRole == UserRole.santri) {
      return const Result.failed('Santri cannot access user lists');
    }

    if (params.currentUserRole == UserRole.admin) {
      if (params.roleToGet == UserRole.superAdmin) {
        return const Result.failed('Admin cannot view Super Admin list');
      }
      if (params.roleToGet != UserRole.santri &&
          params.roleToGet != UserRole.admin) {
        return const Result.failed('Admin can only view Santri or Admin lists');
      }
    }

    // Ambil daftar pengguna berdasarkan role
    final result = await _userRepository.getUsersByRole(role: params.roleToGet);

    if (result.isSuccess) {
      final users = params.includeInactive
          ? result.resultValue!
          : result.resultValue!.where((user) => user.isActive).toList();

      // Log akses ke daftar pengguna
      print(
          'User list accessed by ${params.currentUserRole}: Viewing ${params.roleToGet} users (${users.length} found)');

      return Result.success(users);
    }

    return result;
  }
}
