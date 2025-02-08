import 'package:sti_app/domain/entities/presensi/detail_presensi.dart';

import '../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../domain/entities/presensi/presensi_statistics_data.dart';
import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/result.dart';

abstract interface class PresensiRepository {
  Future<Result<PresensiStatisticsData>> getPresensiStatistics({
    required String programId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Result<DetailPresensi>> getDetailPresensi({
    required String userId,
    required String programId,
    required String bulan,
    required String tahun,
  });
  Future<Result<PresensiSummary>> getPresensiSummary({
    required String userId,
    required String programId,
  });

  Future<Result<PresensiPertemuan>> createPresensiPertemuan(
      PresensiPertemuan presensiPertemuan);

  Future<Result<PresensiPertemuan>> getPresensiPertemuan({
    required String programId,
    required int pertemuanKe,
  });

  Future<Result<List<PresensiPertemuan>>> getAllPresensiPertemuan(
      String programId);

  Future<Result<PresensiPertemuan>> getPresensiById(String id);

  Future<Result<PresensiPertemuan>> updatePresensiPertemuan(
      PresensiPertemuan presensiPertemuan);
  Future<Result<void>> deletePresensiPertemuan(String id);
  Future<Result<List<PresensiPertemuan>>> getRecentPresensiPertemuan({
    required String programId,
    int? limit,
  });
}
