// get_all_programs.dart

import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

class GetAllPrograms implements Usecase<Result<List<Program>>, String> {
  final ProgramRepository _programRepository;

  GetAllPrograms({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<List<Program>>> call(String currentUserRole) async {
    try {
      // Admin dan superAdmin dapat melihat semua program
      // Santri hanya bisa lihat program yang aktif
      final result = await _programRepository.getAllPrograms();

      if (result.isFailed) {
        return result;
      }

      if (currentUserRole == 'santri') {
        // Filter hanya program aktif untuk santri
        final programs = result.resultValue!
            .where((program) =>
                program.totalPertemuan != null && program.totalPertemuan! > 0)
            .toList();

        return Result.success(programs);
      }

      return result;
    } catch (e) {
      return Result.failed('Gagal mengambil daftar program: ${e.toString()}');
    }
  }
}
