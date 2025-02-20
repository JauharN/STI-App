import 'package:flutter/material.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'get_program_by_id_params.dart';

class GetProgramById implements Usecase<Result<Program>, GetProgramByIdParams> {
  final ProgramRepository _programRepository;

  GetProgramById({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(GetProgramByIdParams params) async {
    try {
      if (params.programId.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      final result = await _programRepository.getProgramById(params.programId);

      if (result.isFailed) {
        debugPrint('Failed to get program: ${result.errorMessage}');
        return result;
      }

      // Validasi program untuk role santri
      if (params.currentUserRole == 'santri') {
        final program = result.resultValue!;
        if (program.totalPertemuan == null || program.totalPertemuan! <= 0) {
          debugPrint('Program not available for santri: ${params.programId}');
          return const Result.failed('Program tidak tersedia');
        }
      }

      debugPrint('Successfully retrieved program: ${params.programId}');
      return result;
    } catch (e) {
      debugPrint('Error getting program: $e');
      return Result.failed('Gagal mendapatkan detail program: ${e.toString()}');
    }
  }
}
