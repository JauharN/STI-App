import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/presensi/program_detail.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/program.dart';

abstract interface class ProgramRepository {
  Future<Result<Program>> createProgram(Program program);
  Future<Result<List<Program>>> getAllPrograms();
  Future<Result<Program>> getProgramById(String programId);
  Future<Result<Program>> updateProgram(Program program);
  Future<Result<void>> deleteProgram(String programId);
  Future<Result<List<Program>>> getProgramsByUserId(String userId);
  Future<Result<(ProgramDetail, PresensiSummary)>> getProgramDetailWithStats({
    required String programId,
    required String requestingUserId,
  });
  // Method baru untuk validasi kombinasi program
  Future<Result<bool>> validateProgramCombination(List<String> programIds);

  // Method untuk get available programs
  Future<Result<List<Program>>> getAvailablePrograms();

  // Helper untuk cek valid program
  static bool isValidProgram(String programId) {
    return ['TAHFIDZ', 'GMM', 'IFIS'].contains(programId.toUpperCase());
  }

  // Helper untuk cek kombinasi valid
  static bool isValidCombination(List<String> programIds) {
    // GMM dan IFIS tidak bisa diambil bersamaan
    if (programIds.contains('GMM') && programIds.contains('IFIS')) {
      return false;
    }
    return true;
  }
}
