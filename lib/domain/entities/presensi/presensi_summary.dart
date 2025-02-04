import 'package:freezed_annotation/freezed_annotation.dart';
import '../json_converters.dart';

part 'presensi_summary.freezed.dart';
part 'presensi_summary.g.dart';

@freezed
class PresensiSummary with _$PresensiSummary {
  factory PresensiSummary({
    required int totalSantri,
    required int hadir,
    required int sakit,
    required int izin,
    required int alpha,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _PresensiSummary;

  factory PresensiSummary.validated({
    required int totalSantri,
    required int hadir,
    required int sakit,
    required int izin,
    required int alpha,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (totalSantri <= 0) {
      throw ArgumentError('Total santri harus lebih dari 0');
    }

    final totalStatus = hadir + sakit + izin + alpha;
    if (totalStatus != totalSantri) {
      throw ArgumentError(
          'Total status ($totalStatus) tidak sesuai dengan total santri ($totalSantri)');
    }

    if (hadir < 0 || sakit < 0 || izin < 0 || alpha < 0) {
      throw ArgumentError('Jumlah status tidak boleh negatif');
    }

    return PresensiSummary(
      totalSantri: totalSantri,
      hadir: hadir,
      sakit: sakit,
      izin: izin,
      alpha: alpha,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory PresensiSummary.fromJson(Map<String, dynamic> json) =>
      _$PresensiSummaryFromJson(json);
}

extension PresensiSummaryX on PresensiSummary {
  double get persentaseKehadiran => (hadir / totalSantri) * 100;
  double get persentaseSakit => (sakit / totalSantri) * 100;
  double get persentaseIzin => (izin / totalSantri) * 100;
  double get persentaseAlpha => (alpha / totalSantri) * 100;

  bool get isValid {
    if (totalSantri <= 0) return false;
    if (hadir < 0 || sakit < 0 || izin < 0 || alpha < 0) return false;
    return (hadir + sakit + izin + alpha) == totalSantri;
  }
}
