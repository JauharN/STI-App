import '../../domain/entities/result.dart';
import '../../domain/entities/progres_hafalan.dart';

abstract interface class ProgresHafalanRepository {
  Future<Result<ProgresHafalan>> createProgresHafalan(
      ProgresHafalan progresHafalan);
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByUserId(String userId);
  Future<Result<ProgresHafalan>> updateProgresHafalan(
      ProgresHafalan progresHafalan);
  Future<Result<void>> deleteProgresHafalan(String progresHafalanId);
  Future<Result<ProgresHafalan>> getLatestProgresHafalan(String userId);
}
