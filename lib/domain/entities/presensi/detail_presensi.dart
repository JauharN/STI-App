import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';

part 'detail_presensi.freezed.dart';
part 'detail_presensi.g.dart';

@freezed
class DetailPresensi with _$DetailPresensi {
  factory DetailPresensi({
    required String programId,
    required String programName,
    required String kelas,
    required String pengajarName,
    required List<PresensiDetailItem> pertemuan,
    PresensiSummary?
        summary, // Tambahkan ringkasan presensi dengan tipe yang jelas
  }) = _DetailPresensi;

  factory DetailPresensi.fromJson(Map<String, dynamic> json) =>
      _$DetailPresensiFromJson(json);
}

@freezed
class PresensiDetailItem with _$PresensiDetailItem {
  factory PresensiDetailItem({
    required int pertemuanKe,
    required PresensiStatus status, // Gunakan enum
    @TimestampConverter() required DateTime tanggal,
    String? materi,
    String? keterangan,
  }) = _PresensiDetailItem;

  factory PresensiDetailItem.fromJson(Map<String, dynamic> json) =>
      _$PresensiDetailItemFromJson(json);
}
