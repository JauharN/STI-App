part of 'create_presensi_pertemuan.dart';

class CreatePresensiPertemuanParams {
  final String programId;
  final int pertemuanKe;
  final DateTime tanggal;
  final List<SantriPresensi> daftarHadir;
  final String? materi;
  final String? catatan;
  final String currentUserRole;
  final String userId;

  CreatePresensiPertemuanParams({
    required this.programId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.daftarHadir,
    required this.currentUserRole,
    required this.userId,
    this.materi,
    this.catatan,
  });
}
