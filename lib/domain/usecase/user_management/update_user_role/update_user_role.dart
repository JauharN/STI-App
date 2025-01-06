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
    if (params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed('Only Super Admin can change roles');
    }

    if (params.newRole == UserRole.superAdmin) {
      return const Result.failed('Cannot assign Super Admin role');
    }

    final userResult = await _userRepository.getUser(uid: params.uid);
    if (userResult.isFailed) return userResult;

    final currentUser = userResult.resultValue!;
    if (currentUser.role == UserRole.superAdmin) {
      return const Result.failed('Cannot modify Super Admin role');
    }

    final updatedUser = currentUser.copyWith(role: params.newRole);
    return _userRepository.updateUser(user: updatedUser);
  }
}
