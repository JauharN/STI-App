import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';

part 'delete_program_params.dart';

class DeleteProgram implements Usecase<Result<void>, DeleteProgramParams> {
  final ProgramRepository _programRepository;

  DeleteProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<void>> call(DeleteProgramParams params) async {
    try {
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya admin dan superAdmin yang dapat menghapus program');
      }

      if (params.programId.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // Protect default programs
      final defaultPrograms = ['TAHFIDZ-01', 'GMM-01', 'IFIS-01'];
      if (defaultPrograms.contains(params.programId)) {
        return const Result.failed('Program default STI tidak dapat dihapus');
      }

      // Verify program exists and get enrolled students
      final programResult =
          await _programRepository.getProgramById(params.programId);
      if (programResult.isFailed) {
        return Result.failed(
            'Program tidak ditemukan: ${programResult.errorMessage}');
      }

      return await _programRepository.deleteProgram(params.programId);
    } catch (e) {
      return Result.failed('Gagal menghapus program: ${e.toString()}');
    }
  }
}
