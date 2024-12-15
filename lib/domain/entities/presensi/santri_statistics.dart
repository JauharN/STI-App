import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';

part 'santri_statistics.freezed.dart';
part 'santri_statistics.g.dart';

@freezed
class SantriStatistics with _$SantriStatistics {
  factory SantriStatistics({
    required String santriId,
    required String santriName,
    required int totalKehadiran,
    required int totalPertemuan,
    required Map<PresensiStatus, int> statusCount,
    required double persentaseKehadiran,
  }) = _SantriStatistics;

  factory SantriStatistics.fromJson(Map<String, dynamic> json) =>
      _$SantriStatisticsFromJson(json);
}
