part of 'update_presensi_pertemuan.dart';

class UpdatePresensiPertemuanParams {
  final String id;
  final String programId;
  final int pertemuanKe;
  final DateTime tanggal;
  final List<SantriPresensi> daftarHadir;
  final PresensiSummary summary;
  final String? materi;
  final String? catatan;
  final UserRole currentUserRole;

  UpdatePresensiPertemuanParams({
    required this.id,
    required this.programId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.daftarHadir,
    required this.summary,
    required this.currentUserRole,
    this.materi,
    this.catatan,
  });
}
