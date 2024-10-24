part of 'create_presensi.dart';

class CreatePresensiParams {
  final String userId;
  final String programId;
  final DateTime tanggal;
  final String status; // 'HADIR', 'IZIN', 'SAKIT', 'ALPHA'
  final String? keterangan;

  CreatePresensiParams({
    required this.userId,
    required this.programId,
    required this.tanggal,
    required this.status,
    this.keterangan,
  });
}
