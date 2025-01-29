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
    // Validasi role pengguna
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Access denied: Only admin or superAdmin can view santri lists.');
    }

    try {
      return await _userRepository.getSantriByProgramId(params.programId);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
