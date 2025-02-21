import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import '../json_converters.dart';

part 'presensi_pertemuan.freezed.dart';
part 'presensi_pertemuan.g.dart';

@freezed
class PresensiPertemuan with _$PresensiPertemuan {
  static bool canManage(String role) => role == 'admin' || role == 'superAdmin';
  static bool canView(String role) => true;

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
    String? createdBy,
    String? updatedBy,
  }) = _PresensiPertemuan;

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
    String? createdBy,
    String? updatedBy,
  }) {
    if (pertemuanKe <= 0) {
      throw ArgumentError('Nomor pertemuan harus positif');
    }

    if (!TimestampConverter.isValidTimestamp(tanggal)) {
      throw ArgumentError('Tanggal pertemuan tidak valid');
    }

    if (daftarHadir.isEmpty) {
      throw ArgumentError('Daftar hadir tidak boleh kosong');
    }

    if (!summary.isValid) {
      throw ArgumentError('Summary presensi tidak valid');
    }

    if (summary.totalSantri != daftarHadir.length) {
      throw ArgumentError(
          'Total santri di summary tidak sesuai dengan daftar hadir');
    }

    for (var santri in daftarHadir) {
      if (!santri.isValid) {
        throw ArgumentError(
            'Data presensi untuk santri ${santri.santriName} tidak valid');
      }
    }

    // Standardize timestamps
    final standardizedTanggal = TimestampConverter.standardizeDateTime(tanggal);
    if (standardizedTanggal == null) {
      throw ArgumentError('Gagal memformat tanggal pertemuan');
    }

    final now = DateTime.now();
    final standardizedCreatedAt =
        TimestampConverter.standardizeDateTime(createdAt ?? now);
    final standardizedUpdatedAt =
        TimestampConverter.standardizeDateTime(updatedAt ?? now);

    return PresensiPertemuan(
      id: id,
      programId: programId,
      pertemuanKe: pertemuanKe,
      tanggal: standardizedTanggal,
      daftarHadir: daftarHadir,
      summary: summary,
      materi: materi,
      catatan: catatan,
      createdAt: standardizedCreatedAt,
      updatedAt: standardizedUpdatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  factory PresensiPertemuan.fromJson(Map<String, dynamic> json) =>
      _$PresensiPertemuanFromJson(json);
}

extension PresensiPertemuanX on PresensiPertemuan {
  bool get isValid {
    if (pertemuanKe <= 0) return false;
    if (!TimestampConverter.isValidTimestamp(tanggal)) return false;
    if (daftarHadir.isEmpty) return false;
    if (!summary.isValid) return false;
    if (summary.totalSantri != daftarHadir.length) return false;
    return daftarHadir.every((santri) => santri.isValid);
  }

  bool canBeUpdatedBy(String role) => PresensiPertemuan.canManage(role);
  bool canBeDeletedBy(String role) => PresensiPertemuan.canManage(role);

  Duration? getSinceCreated() {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!);
  }

  Duration? getSinceUpdated() {
    if (updatedAt == null) return null;
    return DateTime.now().difference(updatedAt!);
  }
}
