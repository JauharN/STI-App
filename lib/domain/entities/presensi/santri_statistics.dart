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

  factory SantriStatistics.validated({
    required String santriId,
    required String santriName,
    required int totalKehadiran,
    required int totalPertemuan,
    required Map<PresensiStatus, int> statusCount,
    required double persentaseKehadiran,
  }) {
    if (santriId.isEmpty || santriName.isEmpty) {
      throw ArgumentError('ID dan nama santri tidak boleh kosong');
    }
    if (totalPertemuan <= 0) {
      throw ArgumentError('Total pertemuan harus lebih dari 0');
    }
    if (totalKehadiran < 0 || totalKehadiran > totalPertemuan) {
      throw ArgumentError('Total kehadiran tidak valid');
    }
    if (statusCount.isEmpty) {
      throw ArgumentError('Status count tidak boleh kosong');
    }
    if (persentaseKehadiran < 0 || persentaseKehadiran > 100) {
      throw ArgumentError('Persentase kehadiran harus antara 0-100');
    }

    final totalStatus = statusCount.values.fold(0, (a, b) => a + b);
    if (totalStatus != totalPertemuan) {
      throw ArgumentError('Total status tidak sesuai dengan total pertemuan');
    }

    return SantriStatistics(
      santriId: santriId,
      santriName: santriName,
      totalKehadiran: totalKehadiran,
      totalPertemuan: totalPertemuan,
      statusCount: statusCount,
      persentaseKehadiran: persentaseKehadiran,
    );
  }

  factory SantriStatistics.fromJson(Map<String, dynamic> json) =>
      _$SantriStatisticsFromJson(json);
}

extension SantriStatisticsX on SantriStatistics {
  bool get isValid {
    if (santriId.isEmpty || santriName.isEmpty) return false;
    if (totalPertemuan <= 0 || totalKehadiran < 0) return false;
    if (totalKehadiran > totalPertemuan) return false;
    if (persentaseKehadiran < 0 || persentaseKehadiran > 100) return false;
    final totalStatus = statusCount.values.fold(0, (a, b) => a + b);
    return totalStatus == totalPertemuan;
  }

  int getStatusCount(PresensiStatus status) => statusCount[status] ?? 0;

  double getStatusPercentage(PresensiStatus status) {
    final count = getStatusCount(status);
    return totalPertemuan > 0 ? (count / totalPertemuan) * 100 : 0;
  }
}
