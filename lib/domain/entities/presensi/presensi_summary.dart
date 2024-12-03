// domain/entities/presensi_summary.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_converters.dart';

part 'presensi_summary.freezed.dart';
part 'presensi_summary.g.dart';

@freezed
class PresensiSummary with _$PresensiSummary {
  // Factory constructor biasa tanpa validasi
  factory PresensiSummary({
    required int totalSantri,
    required int hadir,
    required int sakit,
    required int izin,
    required int alpha,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _PresensiSummary;

  // Factory constructor fromJson
  factory PresensiSummary.fromJson(Map<String, dynamic> json) =>
      _$PresensiSummaryFromJson(json);

  // Buat constructor baru untuk validasi
  factory PresensiSummary.validated({
    required int totalSantri,
    required int hadir,
    required int sakit,
    required int izin,
    required int alpha,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (hadir + sakit + izin + alpha != totalSantri) {
      throw ArgumentError('Total status tidak sesuai dengan total santri');
    }

    return PresensiSummary(
      totalSantri: totalSantri,
      hadir: hadir,
      sakit: sakit,
      izin: izin,
      alpha: alpha,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Extension untuk method tambahan
extension PresensiSummaryX on PresensiSummary {
  double get persentaseKehadiran => (hadir / totalSantri) * 100;
  double get persentaseSakit => (sakit / totalSantri) * 100;
  double get persentaseIzin => (izin / totalSantri) * 100;
  double get persentaseAlpha => (alpha / totalSantri) * 100;
}
