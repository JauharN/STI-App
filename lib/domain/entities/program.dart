import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'program.freezed.dart';
part 'program.g.dart';

@freezed
class Program with _$Program {
  factory Program({
    required String id,
    required String nama, // TAHFIDZ, GMM, IFIS
    required String deskripsi,
    required List<String> jadwal,
    String? lokasi,
    String? pengajarId,
    String? pengajarName,
    String? kelas,
    int? totalPertemuan,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Program;

  factory Program.fromJson(Map<String, dynamic> json) =>
      _$ProgramFromJson(json);
}
