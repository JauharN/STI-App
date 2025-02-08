part of 'update_progres_hafalan.dart';

class UpdateProgresHafalanParams {
  final String id;
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
  final DateTime? createdAt;
  final String? createdBy;

  UpdateProgresHafalanParams({
    required this.id,
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
    this.createdAt,
    this.createdBy,
  }) {
    // Validasi ID dan user
    if (id.isEmpty) {
      throw ArgumentError('ID progres hafalan tidak boleh kosong');
    }

    // Validasi fields sesuai program
    if (programId == 'TAHFIDZ') {
      if (juz == null ||
          halaman == null ||
          ayat == null ||
          surah?.isEmpty == true ||
          statusPenilaian?.isEmpty == true) {
        throw ArgumentError('Data Tahfidz tidak lengkap');
      }

      if (!['Lancar', 'Belum', 'Perlu Perbaikan'].contains(statusPenilaian)) {
        throw ArgumentError('Status penilaian tidak valid');
      }
    } else if (programId == 'GMM') {
      if (iqroLevel == null ||
          iqroHalaman == null ||
          statusIqro?.isEmpty == true ||
          mutabaahTarget?.isEmpty == true ||
          statusMutabaah?.isEmpty == true) {
        throw ArgumentError('Data GMM tidak lengkap');
      }

      if (!['1', '2', '3', '4', '5', '6'].contains(iqroLevel)) {
        throw ArgumentError('Level Iqro tidak valid');
      }

      if (!['Lancar', 'Belum'].contains(statusIqro)) {
        throw ArgumentError('Status Iqro tidak valid');
      }

      if (!['Tercapai', 'Belum'].contains(statusMutabaah)) {
        throw ArgumentError('Status Mutabaah tidak valid');
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
