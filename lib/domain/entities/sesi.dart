import 'package:freezed_annotation/freezed_annotation.dart';

part 'sesi.freezed.dart';
part 'sesi.g.dart';

@freezed
class Sesi with _$Sesi {
  factory Sesi({
    required String id,
    required String programId,
    required DateTime waktuMulai,
    required DateTime waktuSelesai,
    required String pengajarId,
    String? materi,
    String? catatan,
  }) = _Sesi;

  factory Sesi.fromJson(Map<String, dynamic> json) => _$SesiFromJson(json);
}
