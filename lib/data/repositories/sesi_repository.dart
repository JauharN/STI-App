import '../../domain/entities/result.dart';
import '../../domain/entities/sesi.dart';

abstract interface class SesiRepository {
  Future<Result<Sesi>> createSesi(Sesi sesi);
  Future<Result<List<Sesi>>> getSesiByProgramId(String programId);
  Future<Result<Sesi>> updateSesi(Sesi sesi);
  Future<Result<void>> deleteSesi(String sesiId);
  Future<Result<List<Sesi>>> getUpcomingSesi(String programId);
}
