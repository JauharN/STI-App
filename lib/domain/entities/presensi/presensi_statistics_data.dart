import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/santri_statistics.dart';

part 'presensi_statistics_data.freezed.dart';
part 'presensi_statistics_data.g.dart';

@freezed
class PresensiStatisticsData with _$PresensiStatisticsData {
  factory PresensiStatisticsData({
    required String programId,
    required int totalPertemuan,
    required int totalSantri,
    required Map<String, double> trendKehadiran,
    required Map<PresensiStatus, int> totalByStatus,
    required List<SantriStatistics> santriStats,
    DateTime? lastUpdated,
  }) = _PresensiStatisticsData;

  factory PresensiStatisticsData.fromJson(Map<String, dynamic> json) =>
      _$PresensiStatisticsDataFromJson(json);
}
