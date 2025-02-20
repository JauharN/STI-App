import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/usecase/program/validate_program_combination/validate_program_combination.dart';
import '../../repositories/program_repository/program_repository_provider.dart';

part 'validate_program_combination_provider.g.dart';

@riverpod
ValidateProgramCombination validateProgramCombination(
    ValidateProgramCombinationRef ref) {
  return ValidateProgramCombination(
    programRepository: ref.watch(programRepositoryProvider),
  );
}
