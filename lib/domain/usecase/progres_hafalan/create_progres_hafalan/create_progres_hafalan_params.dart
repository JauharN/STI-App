part of 'create_progres_hafalan.dart';

class CreateProgresHafalanParams {
  final String userId;
  final String programId; // 'TAHFIDZ' atau 'GMM'
  final DateTime tanggal;

  // Fields untuk Tahfidz
  final int? juz;
  final int? halaman;
  final int? ayat;

  // Fields untuk GMM
  final String? iqroLevel;
  final int? iqroHalaman;
  final String? mutabaahTarget;

  final String? catatan;

  CreateProgresHafalanParams({
    required this.userId,
    required this.programId,
    required this.tanggal,
    // Fields Tahfidz bersifat opsional karena tergantung programId
    this.juz,
    this.halaman,
    this.ayat,
    // Fields GMM bersifat opsional karena tergantung programId
    this.iqroLevel,
    this.iqroHalaman,
    this.mutabaahTarget,
    this.catatan,
  });
}
