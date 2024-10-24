import 'package:sti_app/data/repositories/authentication.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

import '../../../entities/result.dart';

class Logout implements Usecase<Result<void>, void> {
  final Authentication _authentication;

  Logout({required Authentication authentication})
      : _authentication = authentication;

  @override
  Future<Result<void>> call(void params) {
    return _authentication.logout();
  }
}
