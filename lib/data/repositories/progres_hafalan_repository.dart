import '../../domain/entities/result.dart';
import '../../domain/entities/progres_hafalan.dart';

abstract interface class ProgresHafalanRepository {
  /// Creates a new progres hafalan entry
  Future<Result<ProgresHafalan>> createProgresHafalan(
      ProgresHafalan progresHafalan);

  /// Get all progres hafalan entries for a specific user
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByUserId(String userId);

  /// Updates existing progres hafalan entry
  Future<Result<ProgresHafalan>> updateProgresHafalan(
      ProgresHafalan progresHafalan);

  /// Deletes progres hafalan entry by ID
  Future<Result<void>> deleteProgresHafalan(String progresHafalanId);

  /// Gets latest progres hafalan entry for a user
  Future<Result<ProgresHafalan>> getLatestProgresHafalan(String userId);

  /// Gets progres hafalan filtered by program
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByProgramId(
      String programId);

  /// Gets progres hafalan within date range
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
