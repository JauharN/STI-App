import '../../domain/entities/result.dart';
import '../../domain/entities/presensi.dart';

abstract interface class PresensiRepository {
  Future<Result<Presensi>> createPresensi(Presensi presensi);
  Future<Result<List<Presensi>>> getPresensiByUserId(String userId);
  Future<Result<List<Presensi>>> getPresensiByProgramId(String programId);
  Future<Result<Presensi>> updatePresensi(Presensi presensi);
  Future<Result<void>> deletePresensi(String presensiId);
}
