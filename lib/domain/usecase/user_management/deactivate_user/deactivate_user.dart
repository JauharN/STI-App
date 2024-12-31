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
    if (params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed('Only Super Admin can deactivate users');
    }

    final userResult = await _userRepository.getUser(uid: params.uid);
    if (userResult.isFailed) return userResult;

    final user = userResult.resultValue!;
    if (user.role == UserRole.superAdmin) {
      return const Result.failed('Cannot deactivate Super Admin users');
    }

    if (!user.isActive) {
      return const Result.failed('User is already inactive');
    }

    final updatedUser = user.copyWith(isActive: false);
    return _userRepository.updateUser(user: updatedUser);
  }
}
