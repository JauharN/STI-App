import 'package:flutter/material.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';

part 'validate_program_combination_params.dart';

class ValidateProgramCombination
    implements Usecase<Result<bool>, ValidateProgramCombinationParams> {
  final ProgramRepository _programRepository;

  ValidateProgramCombination({
    required ProgramRepository programRepository,
  }) : _programRepository = programRepository;

  @override
  Future<Result<bool>> call(ValidateProgramCombinationParams params) async {
    try {
      // 1. Basic validation
      if (params.programIds.isEmpty) {
        return const Result.failed('Pilih minimal 1 program');
      }

      if (params.programIds.length > 3) {
        return const Result.failed('Maksimal pilih 3 program');
      }

      // 2. Validate valid programs
      for (String programId in params.programIds) {
        if (!ProgramRepository.isValidProgram(programId)) {
          return Result.failed('Program $programId tidak valid');
        }
      }

      // 3. Check for duplicates
      if (params.programIds.toSet().length != params.programIds.length) {
        return const Result.failed('Program tidak boleh duplikat');
      }

      // 4. Check program combination validity
      final result = await _programRepository.validateProgramCombination(
        params.programIds,
      );

      if (result.isSuccess) {
        debugPrint(
            'Program combination validated successfully: ${params.programIds}');
      } else {
        debugPrint(
            'Program combination validation failed: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error validating program combination: $e');
      return Result.failed(
          'Gagal memvalidasi kombinasi program: ${e.toString()}');
    }
  }
}
