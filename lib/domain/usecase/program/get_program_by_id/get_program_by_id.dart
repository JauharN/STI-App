import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/program.dart';

part 'get_program_by_id_params.dart';

class GetProgramById implements Usecase<Result<Program>, GetProgramByIdParams> {
  final ProgramRepository _programRepository;

  GetProgramById({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(GetProgramByIdParams params) async {
    // Validasi program ID
    if (params.programId.isEmpty) {
      return const Result.failed('Program ID cannot be empty');
    }

    // Ambil data program berdasarkan ID
    return _programRepository.getProgramById(params.programId);
  }
}
