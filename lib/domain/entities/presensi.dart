import 'package:freezed_annotation/freezed_annotation.dart';

part 'presensi.freezed.dart';
part 'presensi.g.dart';

@freezed
class Presensi with _$Presensi {
  factory Presensi({
    required String id,
    required String userId,
    required String programId, // 'TAHFIDZ', 'GMM', 'IFIS'
    required DateTime tanggal,
    required String status,
    required int pertemuanKe,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Presensi;

  factory Presensi.fromJson(Map<String, dynamic> json) =>
      _$PresensiFromJson(json);
}
