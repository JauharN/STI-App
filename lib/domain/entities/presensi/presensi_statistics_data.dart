import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/santri_statistics.dart';

part 'presensi_statistics_data.freezed.dart';
part 'presensi_statistics_data.g.dart';

@freezed
class PresensiStatisticsData with _$PresensiStatisticsData {
  static bool canAccess(String role) => role == 'admin' || role == 'superAdmin';

  factory PresensiStatisticsData({
    required String programId,
    required int totalPertemuan,
    required int totalSantri,
    required Map<String, double> trendKehadiran,
    required Map<PresensiStatus, int> totalByStatus,
    required List<SantriStatistics> santriStats,
    @Default(null) DateTime? lastUpdated,
  }) = _PresensiStatisticsData;

  factory PresensiStatisticsData.validated({
    required String programId,
    required int totalPertemuan,
    required int totalSantri,
    required Map<String, double> trendKehadiran,
    required Map<PresensiStatus, int> totalByStatus,
    required List<SantriStatistics> santriStats,
    DateTime? lastUpdated,
  }) {
    if (programId.isEmpty) {
      throw ArgumentError('Program ID tidak boleh kosong');
    }
    if (totalPertemuan <= 0) {
      throw ArgumentError('Total pertemuan harus lebih dari 0');
    }
    if (totalSantri <= 0) {
      throw ArgumentError('Total santri harus lebih dari 0');
    }
    if (trendKehadiran.isEmpty) {
      throw ArgumentError('Trend kehadiran tidak boleh kosong');
    }
    if (santriStats.isEmpty) {
      throw ArgumentError('Statistik santri tidak boleh kosong');
    }
    if (santriStats.length != totalSantri) {
      throw ArgumentError(
          'Jumlah statistik santri tidak sesuai dengan total santri');
    }

    return PresensiStatisticsData(
      programId: programId,
      totalPertemuan: totalPertemuan,
      totalSantri: totalSantri,
      trendKehadiran: trendKehadiran,
      totalByStatus: totalByStatus,
      santriStats: santriStats,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  factory PresensiStatisticsData.fromJson(Map<String, dynamic> json) =>
      _$PresensiStatisticsDataFromJson(json);
}

extension PresensiStatisticsDataX on PresensiStatisticsData {
  bool get isValid {
    if (programId.isEmpty || totalPertemuan <= 0 || totalSantri <= 0)
      return false;
    if (trendKehadiran.isEmpty || santriStats.isEmpty) return false;
    if (santriStats.length != totalSantri) return false;
    return true;
  }

  double get averageKehadiran {
    if (trendKehadiran.isEmpty) return 0;
    final total = trendKehadiran.values.reduce((a, b) => a + b);
    return total / trendKehadiran.length;
  }
}
