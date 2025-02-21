part of 'create_program.dart';

class CreateProgramParams {
  final String nama;
  final String deskripsi;
  final List<String> jadwal;
  final String? lokasi;
  final String? kelas;
  final int? totalPertemuan;
  final String currentUserRole;
  final List<String>? initialTeacherIds;
  final List<String>? initialTeacherNames;
  final List<String>? enrolledSantriIds;

  CreateProgramParams({
    required this.nama,
    required this.deskripsi,
    required this.jadwal,
    required this.currentUserRole,
    this.lokasi,
    this.kelas,
    this.totalPertemuan,
    this.initialTeacherIds,
    this.initialTeacherNames,
    this.enrolledSantriIds,
  }) {
    // Validasi saat konstruksi
    if (nama.isEmpty) {
      throw ArgumentError('Nama program tidak boleh kosong');
    }
    if (deskripsi.isEmpty) {
      throw ArgumentError('Deskripsi program tidak boleh kosong');
    }
    if (jadwal.isEmpty) {
      throw ArgumentError('Jadwal tidak boleh kosong');
    }
    if (!['admin', 'superAdmin'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid untuk membuat program');
    }
    if (initialTeacherIds != null && initialTeacherNames != null) {
      if (initialTeacherIds!.length != initialTeacherNames!.length) {
        throw ArgumentError('Jumlah ID dan nama pengajar harus sama');
      }
    }
  }
}
