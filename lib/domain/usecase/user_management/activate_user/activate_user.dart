import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'activate_user_params.dart';

class ActivateUser implements Usecase<Result<User>, ActivateUserParams> {
  final UserRepository _userRepository;

  ActivateUser({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(ActivateUserParams params) async {
    if (params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed('Only Super Admin can activate users');
    }

    final userResult = await _userRepository.getUser(uid: params.uid);
    if (userResult.isFailed) return userResult;

    final user = userResult.resultValue!;
    if (user.isActive) {
      return const Result.failed('User is already active');
    }

    final updatedUser = user.copyWith(isActive: true);
    return _userRepository.updateUser(user: updatedUser);
  }
}
