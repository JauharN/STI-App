import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';

import '../json_converters.dart';
import 'santri_presensi.dart';

part 'presensi_pertemuan.freezed.dart';
part 'presensi_pertemuan.g.dart';

@freezed
class PresensiPertemuan with _$PresensiPertemuan {
  // Factory constructor biasa tanpa validasi
  factory PresensiPertemuan({
    required String id,
    required String programId,
    required int pertemuanKe,
    @TimestampConverter() required DateTime tanggal,
    required List<SantriPresensi> daftarHadir,
    required PresensiSummary summary,
    String? materi,
    String? catatan,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _PresensiPertemuan;

  // Factory constructor fromJson
  factory PresensiPertemuan.fromJson(Map<String, dynamic> json) =>
      _$PresensiPertemuanFromJson(json);

  // Buat constructor baru untuk validasi
  factory PresensiPertemuan.validated({
    required String id,
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required List<SantriPresensi> daftarHadir,
    required PresensiSummary summary,
    String? materi,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (pertemuanKe <= 0) {
      throw ArgumentError('Nomor pertemuan harus positif');
    }
    if (tanggal.isAfter(DateTime.now())) {
      throw ArgumentError('Tanggal tidak boleh di masa depan');
    }
    if (daftarHadir.isEmpty) {
      throw ArgumentError('Daftar hadir tidak boleh kosong');
    }

    return PresensiPertemuan(
      id: id,
      programId: programId,
      pertemuanKe: pertemuanKe,
      tanggal: tanggal,
      daftarHadir: daftarHadir,
      summary: summary,
      materi: materi,
      catatan: catatan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Extension untuk method tambahan
extension PresensiPertemuanX on PresensiPertemuan {
  bool get isValid {
    return id.isNotEmpty &&
        pertemuanKe > 0 &&
        !tanggal.isAfter(DateTime.now()) &&
        daftarHadir.isNotEmpty;
  }
}
