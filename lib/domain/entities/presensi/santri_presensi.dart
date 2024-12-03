import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';

part 'santri_presensi.freezed.dart';
part 'santri_presensi.g.dart';

@freezed
class SantriPresensi with _$SantriPresensi {
  factory SantriPresensi({
    required String santriId,
    required String santriName, // Tambahkan ini
    required PresensiStatus status, // Ubah ke enum
    String? keterangan,
  }) = _SantriPresensi;

  factory SantriPresensi.fromJson(Map<String, dynamic> json) =>
      _$SantriPresensiFromJson(json);
}
