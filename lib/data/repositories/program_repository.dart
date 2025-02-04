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
}
