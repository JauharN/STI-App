import 'package:flutter/material.dart';
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
      // Role validation
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya admin dan superAdmin yang dapat menghapus program');
      }

      // Validasi program ID
      if (params.programId.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // Protect default programs
      if (['TAHFIDZ', 'GMM', 'IFIS'].contains(params.programId)) {
        return const Result.failed('Program default STI tidak dapat dihapus');
      }

      // Delete program
      final result = await _programRepository.deleteProgram(params.programId);

      if (result.isSuccess) {
        debugPrint('Successfully deleted program: ${params.programId}');
      } else {
        debugPrint('Failed to delete program: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error deleting program: $e');
      return Result.failed('Gagal menghapus program: ${e.toString()}');
    }
  }
}
