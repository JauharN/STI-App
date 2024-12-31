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
    if (params.currentUserRole == UserRole.santri) {
      return const Result.failed('Santri cannot access user lists');
    }

    if (params.currentUserRole == UserRole.admin &&
        params.roleToGet == UserRole.superAdmin) {
      return const Result.failed('Admin cannot view Super Admin list');
    }

    final result = await _userRepository.getUsersByRole(role: params.roleToGet);

    if (result.isSuccess && !params.includeInactive) {
      final activeUsers =
          result.resultValue!.where((user) => user.isActive).toList();
      return Result.success(activeUsers);
    }

    return result;
  }
}
