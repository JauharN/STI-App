part of 'create_program.dart';

class CreateProgramParams {
  final String nama; // Harus salah satu dari: 'TAHFIDZ', 'GMM', 'IFIS'
  final String deskripsi;
  final List<String> jadwal;
  final String? lokasi;
  final UserRole currentUserRole;

  CreateProgramParams({
    required this.nama,
    required this.deskripsi,
    required this.jadwal,
    required this.currentUserRole,
    this.lokasi,
  });
}
