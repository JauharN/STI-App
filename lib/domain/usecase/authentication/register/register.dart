import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/authentication/register/register_params.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

import '../../../entities/result.dart';
import '../../../entities/user.dart';

class Register implements Usecase<Result<User>, RegisterParams> {
  final Authentication _authentication;
  final UserRepository _userRepository;

  Register(
      {required Authentication authentication,
      required UserRepository userRepository})
      : _authentication = authentication,
        _userRepository = userRepository;

  @override
  Future<Result<User>> call(RegisterParams params) async {
    var uidResult = await _authentication.register(
        email: params.email, password: params.password);

    if (uidResult.isSuccess) {
      var userResult = await _userRepository.createUser(
        uid: uidResult.resultValue!,
        email: params.email,
        name: params.name,
        photoUrl: params.photoUrl,
        phoneNumber: params.phoneNumber,
        address: params.address,
        dateOfBirth: params.dateOfBirth,
      );
      if (userResult.isSuccess) {
        return Result.success(userResult.resultValue!);
      } else {
        return Result.failed(userResult.errorMessage!);
      }
    } else {
      return Result.failed(uidResult.errorMessage!);
    }
  }
}
