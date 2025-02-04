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
  final String currentUserRole;
  final String userId;
  final DateTime? createdAt;
  final String? createdBy;

  UpdatePresensiPertemuanParams({
    required this.id,
    required this.programId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.daftarHadir,
    required this.summary,
    required this.currentUserRole,
    required this.userId,
    this.materi,
    this.catatan,
    this.createdAt,
    this.createdBy,
  });
}
