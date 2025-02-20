part of 'validate_program_combination.dart';

class ValidateProgramCombinationParams {
  final List<String> programIds;

  ValidateProgramCombinationParams({
    required this.programIds,
  }) {
    // Validasi input
    if (programIds.isEmpty) {
      throw ArgumentError('List program tidak boleh kosong');
    }

    // Validasi format program IDs
    for (var id in programIds) {
      if (id.isEmpty) {
        throw ArgumentError('ID program tidak boleh kosong');
      }
    }
  }
}
