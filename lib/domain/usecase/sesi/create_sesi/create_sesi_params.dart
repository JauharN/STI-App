part of 'create_sesi.dart';

class CreateSesiParams {
  // Data untuk membuat sesi baru
  final String programId;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final String pengajarId;
  final String? materi;
  final String? catatan;

  CreateSesiParams({
    required this.programId,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.pengajarId,
    this.materi,
    this.catatan,
  });
}
