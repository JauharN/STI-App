import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/presensi/program_detail.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/program.dart';

abstract interface class ProgramRepository {
  // Core CRUD - Esensial untuk operasi dasar
  Future<Result<Program>> createProgram(Program program);
  Future<Result<Program>> getProgramById(String programId);
  Future<Result<Program>> updateProgram(Program program);
  Future<Result<void>> deleteProgram(String programId);

  // Essential Program Operations
  Future<Result<List<Program>>> getAllPrograms();
  Future<Result<List<Program>>> getProgramsByUserId(String userId);

  // Teacher Management - Kritis untuk multiple teachers
  Future<Result<Program>> addTeacherToProgram({
    required String programId,
    required String teacherId,
    required String teacherName,
  });

  // Essential Program Stats & Details
  Future<Result<(ProgramDetail, PresensiSummary)>> getProgramDetailWithStats({
    required String programId,
    required String requestingUserId,
  });

  // Essential Validations
  Future<Result<bool>> validateProgramCombination(List<String> programIds);

  // Static Validators - Helper methods penting
  static bool isValidProgram(String programId) {
    return ['TAHFIDZ', 'GMM', 'IFIS'].contains(programId.toUpperCase());
  }

  static bool isValidCombination(List<String> programIds) {
    // Business rule: GMM dan IFIS tidak bisa diambil bersamaan
    if (programIds.contains('GMM') && programIds.contains('IFIS')) {
      return false;
    }
    // Validasi jumlah program
    if (programIds.length > 3) {
      return false;
    }
    // Validasi program yang valid
    return programIds.every((id) => isValidProgram(id));
  }

  static String getProgramDisplayName(String programId) {
    switch (programId.toUpperCase()) {
      case 'TAHFIDZ':
        return 'Program Tahfidz Al-Quran';
      case 'GMM':
        return 'Program Generasi Menghafal Mandiri';
      case 'IFIS':
        return 'Program Islamic Foundation and Islamic Studies';
      default:
        return 'Unknown Program';
    }
  }

  static bool hasPresensiFeature(String programId) =>
      true; // Semua program punya presensi

  static bool hasProgresHafalanFeature(String programId) {
    // Hanya TAHFIDZ dan GMM yang punya fitur progres hafalan
    return ['TAHFIDZ', 'GMM'].contains(programId.toUpperCase());
  }
}
