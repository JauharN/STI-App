import '../../../data/repositories/user_repository.dart';
import '../../entities/result.dart';
import '../../entities/user.dart';
import '../usecase.dart';

part 'get_santri_by_program_params.dart';

class GetSantriByProgram
    implements Usecase<Result<List<User>>, GetSantriByProgramParams> {
  final UserRepository _userRepository;

  GetSantriByProgram({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  @override
  Future<Result<List<User>>> call(GetSantriByProgramParams params) async {
    try {
      return await _userRepository.getSantriByProgramId(params.programId);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
