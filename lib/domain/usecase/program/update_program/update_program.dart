import 'package:flutter/material.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'update_program_params.dart';

class UpdateProgram implements Usecase<Result<Program>, UpdateProgramParams> {
  final ProgramRepository _programRepository;

  UpdateProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(UpdateProgramParams params) async {
    try {
      // Role validation
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat memperbarui program');
      }

      // Validasi ID program
      if (params.program.id.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // Validasi nama program
      final validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
      if (!validPrograms.contains(params.program.nama.toUpperCase())) {
        return const Result.failed(
            'Nama program harus TAHFIDZ, GMM, atau IFIS');
      }

      // Validasi jadwal
      if (params.program.jadwal.isEmpty) {
        return const Result.failed('Jadwal program tidak boleh kosong');
      }

      // Create updated program object
      final updatedProgram = params.program.copyWith(
        nama: params.program.nama.toUpperCase(),
        updatedAt: DateTime.now(),
      );

      // Update in repository
      return await _programRepository.updateProgram(updatedProgram);
    } catch (e) {
      debugPrint('Error updating program: $e');
      return Result.failed('Gagal memperbarui program: ${e.toString()}');
    }
  }
}
