import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/result.dart';
import '../repositories/program_repository/program_repository_provider.dart';

part 'program_validation_provider.g.dart';

@riverpod
class ProgramValidation extends _$ProgramValidation {
  @override
  Future<bool> build() async {
    return true;
  }

  Future<bool> validateProgramCombination(List<String> programIds) async {
    try {
      final repository = ref.read(programRepositoryProvider);
      final result = await repository.validateProgramCombination(programIds);

      return switch (result) {
        Success(value: final isValid) => isValid,
        Failed(:final message) => throw Exception(message),
      };
    } catch (e) {
      throw Exception('Gagal validasi kombinasi program: ${e.toString()}');
    }
  }

  bool isValidProgramName(String nama) {
    return ['TAHFIDZ', 'GMM', 'IFIS'].contains(nama.toUpperCase());
  }

  bool canCombinePrograms(List<String> programIds) {
    // GMM dan IFIS tidak bisa diambil bersamaan
    if (programIds.contains('GMM') && programIds.contains('IFIS')) {
      return false;
    }

    // Maksimal 3 program
    if (programIds.length > 3) {
      return false;
    }

    // Semua program harus valid
    return programIds.every((id) => isValidProgramName(id));
  }

  String getProgramErrorMessage(List<String> programIds) {
    if (programIds.contains('GMM') && programIds.contains('IFIS')) {
      return 'Program GMM dan IFIS tidak dapat diambil bersamaan';
    }
    if (programIds.length > 3) {
      return 'Maksimal pilih 3 program';
    }
    if (!programIds.every((id) => isValidProgramName(id))) {
      return 'Terdapat program yang tidak valid';
    }
    return '';
  }
}
