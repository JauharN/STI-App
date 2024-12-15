part of 'create_presensi_pertemuan.dart';

class CreatePresensiPertemuanParams {
  final String programId;
  final int pertemuanKe;
  final DateTime tanggal;
  final List<SantriPresensi> daftarHadir;
  final PresensiSummary summary;
  final String? materi;
  final String? catatan;

  CreatePresensiPertemuanParams({
    required this.programId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.daftarHadir,
    required this.summary,
    this.materi,
    this.catatan,
  });
}
