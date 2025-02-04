import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';

part 'santri_presensi.freezed.dart';
part 'santri_presensi.g.dart';

@freezed
class SantriPresensi with _$SantriPresensi {
  factory SantriPresensi({
    required String santriId,
    required String santriName,
    required PresensiStatus status,
    String? keterangan,
  }) = _SantriPresensi;

  // Named constructor untuk validasi lengkap
  factory SantriPresensi.validated({
    required String santriId,
    required String santriName,
    required PresensiStatus status,
    String? keterangan,
  }) {
    if (santriId.isEmpty) {
      throw ArgumentError('ID Santri tidak boleh kosong');
    }

    if (santriName.isEmpty) {
      throw ArgumentError('Nama Santri tidak boleh kosong');
    }

    // Validasi keterangan wajib untuk status selain hadir
    if (status != PresensiStatus.hadir && (keterangan?.isEmpty ?? true)) {
      throw ArgumentError(
          'Keterangan wajib diisi untuk status ${status.label}');
    }

    return SantriPresensi(
      santriId: santriId,
      santriName: santriName,
      status: status,
      keterangan: keterangan,
    );
  }

  factory SantriPresensi.fromJson(Map<String, dynamic> json) =>
      _$SantriPresensiFromJson(json);
}

// Extension untuk method helper
extension SantriPresensiX on SantriPresensi {
  bool get isHadir => status == PresensiStatus.hadir;
  bool get needsKeterangan => !isHadir;

  bool get isValid {
    if (santriId.isEmpty || santriName.isEmpty) return false;
    if (needsKeterangan && (keterangan?.isEmpty ?? true)) return false;
    return true;
  }
}
