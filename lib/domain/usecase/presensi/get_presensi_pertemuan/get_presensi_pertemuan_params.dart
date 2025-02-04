part of 'get_presensi_pertemuan.dart';

class GetPresensiPertemuanParams {
  final String programId;
  final int pertemuanKe;
  final String currentUserRole;

  GetPresensiPertemuanParams({
    required this.programId,
    required this.pertemuanKe,
    required this.currentUserRole,
  });
}
