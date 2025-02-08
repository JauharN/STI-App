part of 'create_progres_hafalan.dart';

class CreateProgresHafalanParams {
  final String userId;
  final String programId;
  final DateTime tanggal;
  final String currentUserRole;

  // Tahfidz fields
  final int? juz;
  final int? halaman;
  final int? ayat;
  final String? surah;
  final String? statusPenilaian;

  // GMM fields
  final String? iqroLevel;
  final int? iqroHalaman;
  final String? statusIqro;
  final String? mutabaahTarget;
  final String? statusMutabaah;

  final String? catatan;

  CreateProgresHafalanParams({
    required this.userId,
    required this.programId,
    required this.tanggal,
    required this.currentUserRole,
    this.juz,
    this.halaman,
    this.ayat,
    this.surah,
    this.statusPenilaian,
    this.iqroLevel,
    this.iqroHalaman,
    this.statusIqro,
    this.mutabaahTarget,
    this.statusMutabaah,
    this.catatan,
  }) {
    // Validasi fields sesuai program
    if (programId == 'TAHFIDZ') {
      if (juz == null ||
          halaman == null ||
          ayat == null ||
          surah?.isEmpty == true ||
          statusPenilaian?.isEmpty == true) {
        throw ArgumentError('Data Tahfidz tidak lengkap');
      }
    } else if (programId == 'GMM') {
      if (iqroLevel == null ||
          iqroHalaman == null ||
          statusIqro?.isEmpty == true ||
          mutabaahTarget?.isEmpty == true ||
          statusMutabaah?.isEmpty == true) {
        throw ArgumentError('Data GMM tidak lengkap');
      }
    } else {
      throw ArgumentError('Program ID tidak valid');
    }

    // Validasi tanggal
    if (tanggal.isAfter(DateTime.now())) {
      throw ArgumentError('Tanggal tidak boleh di masa depan');
    }
  }
}
