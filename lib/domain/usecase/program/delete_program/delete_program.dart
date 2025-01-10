import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';

part 'delete_program_params.dart';

class DeleteProgram implements Usecase<Result<void>, DeleteProgramParams> {
  final ProgramRepository _programRepository;

  DeleteProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<void>> call(DeleteProgramParams params) async {
    // Validasi ID tidak boleh kosong
    if (params.programId.isEmpty) {
      return const Result.failed('Program ID cannot be empty');
    }

    // Validasi program default tidak boleh dihapus
    final defaultPrograms = ['TAHFIDZ-01', 'GMM-01', 'IFIS-01']; // Contoh ID
    if (defaultPrograms.contains(params.programId)) {
      return const Result.failed('Cannot delete default STI programs');
    }

    // Hapus program
    return _programRepository.deleteProgram(params.programId);
  }
}
