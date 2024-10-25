import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/usecase/program/get_programs_by_user_id/get_programs_by_user_id_params.dart';
import '../../../entities/result.dart';
import '../../../entities/program.dart';

class GetProgramsByUserId
    implements Usecase<Result<List<Program>>, GetProgramsByUserIdParams> {
  final ProgramRepository _programRepository;

  GetProgramsByUserId({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<List<Program>>> call(GetProgramsByUserIdParams params) async {
    // Validasi user ID
    if (params.userId.isEmpty) {
      return const Result.failed('User ID cannot be empty');
    }

    // Ambil daftar program yang diikuti santri
    return _programRepository.getProgramsByUserId(params.userId);
  }
}
