part of 'create_program.dart';

class CreateProgramParams {
  final String nama;
  final String deskripsi;
  final List<String> jadwal;
  final String? lokasi;
  final String? pengajarId;
  final String? pengajarName;
  final String? kelas;
  final int? totalPertemuan;
  final String currentUserRole;

  CreateProgramParams({
    required this.nama,
    required this.deskripsi,
    required this.jadwal,
    required this.currentUserRole,
    this.lokasi,
    this.pengajarId,
    this.pengajarName,
    this.kelas,
    this.totalPertemuan,
  });
}
