import 'package:freezed_annotation/freezed_annotation.dart';

part 'progres_hafalan.freezed.dart';
part 'progres_hafalan.g.dart';

@freezed
class ProgresHafalan with _$ProgresHafalan {
  factory ProgresHafalan({
    required String id,
    required String userId,
    required String programId, // 'TAHFIDZ' atau 'GMM'
    // Fields untuk Tahfidz
    int? juz,
    int? halaman,
    int? ayat,
    // Fields untuk GMM
    String? iqroLevel,
    int? iqroHalaman,
    String? mutabaahTarget,
    required DateTime tanggal,
    String? catatan,
  }) = _ProgresHafalan;

  factory ProgresHafalan.fromJson(Map<String, dynamic> json) =>
      _$ProgresHafalanFromJson(json);
}
