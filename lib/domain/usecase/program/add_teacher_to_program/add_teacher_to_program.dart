import 'package:flutter/material.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'add_tecaher_to_program_params.dart';

class AddTeacherToProgram
    implements Usecase<Result<Program>, AddTeacherToProgramParams> {
  final ProgramRepository _programRepository;

  AddTeacherToProgram({
    required ProgramRepository programRepository,
  }) : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(AddTeacherToProgramParams params) async {
    try {
      // Role validation
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat menambah pengajar');
      }

      // Validate program ID
      if (!ProgramRepository.isValidProgram(params.programId)) {
        return Result.failed('Program ${params.programId} tidak valid');
      }

      // Add teacher to program
      final result = await _programRepository.addTeacherToProgram(
        programId: params.programId,
        teacherId: params.teacherId,
        teacherName: params.teacherName,
      );

      if (result.isSuccess) {
        debugPrint(
            'Successfully added teacher to program: ${params.programId}');
      } else {
        debugPrint('Failed to add teacher: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error adding teacher to program: $e');
      return Result.failed('Gagal menambahkan pengajar: ${e.toString()}');
    }
  }
}
