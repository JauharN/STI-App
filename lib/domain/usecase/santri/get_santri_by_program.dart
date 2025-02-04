import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'get_santri_by_program_params.dart';

class GetSantriByProgram
    implements Usecase<Result<List<User>>, GetSantriByProgramParams> {
  final UserRepository _userRepository;

  GetSantriByProgram({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<List<User>>> call(GetSantriByProgramParams params) async {
    try {
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya admin dan superAdmin yang dapat mengakses daftar santri');
      }

      return await _userRepository.getSantriByProgramId(params.programId);
    } catch (e) {
      return Result.failed('Gagal mendapatkan daftar santri: ${e.toString()}');
    }
  }
}
