import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

import '../../../entities/result.dart';
import '../../../entities/user.dart';

part 'login_params.dart';

class Login implements Usecase<Result<User>, LoginParams> {
  final Authentication authentication;
  final UserRepository userRepository;

  Login({required this.authentication, required this.userRepository});

  @override
  Future<Result<User>> call(LoginParams params) async {
    var loginResult = await authentication.login(
      email: params.email,
      password: params.password,
    );

    if (loginResult.isSuccess) {
      var userResult =
          await userRepository.getUser(uid: loginResult.resultValue!);
      if (userResult.isSuccess) {
        return Result.success(userResult.resultValue!);
      } else {
        return Result.failed(userResult.errorMessage!);
      }
    } else {
      return Result.failed(loginResult.errorMessage!);
    }
  }
}
