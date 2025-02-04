part of 'delete_presensi_pertemuan.dart';

class DeletePresensiPertemuanParams {
  final String id;
  final String programId;
  final int pertemuanKe;
  final String currentUserRole;

  DeletePresensiPertemuanParams({
    required this.id,
    required this.programId,
    required this.pertemuanKe,
    required this.currentUserRole,
  });
}
