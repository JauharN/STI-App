import 'package:flutter/foundation.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'get_all_programs_params.dart';

class GetAllPrograms
    implements Usecase<Result<List<Program>>, GetAllProgramsParams> {
  final ProgramRepository _programRepository;

  GetAllPrograms({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<List<Program>>> call(GetAllProgramsParams params) async {
    try {
      // Get all programs from repository
      final result = await _programRepository.getAllPrograms();

      if (result.isFailed) {
        debugPrint('Failed to get programs: ${result.errorMessage}');
        return result;
      }

      // Filter for santri role - hanya program aktif
      if (params.currentUserRole == 'santri') {
        final programs = result.resultValue!
            .where((program) =>
                program.totalPertemuan != null && program.totalPertemuan! > 0)
            .toList();

        debugPrint('Filtered ${programs.length} active programs for santri');
        return Result.success(programs);
      }

      debugPrint('Retrieved all programs successfully');
      return result;
    } catch (e) {
      debugPrint('Error getting programs: $e');
      return Result.failed('Gagal mengambil daftar program: ${e.toString()}');
    }
  }
}
