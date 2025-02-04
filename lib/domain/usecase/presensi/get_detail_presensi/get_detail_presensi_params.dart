part of 'get_detail_presensi.dart';

class GetDetailPresensiParams {
  final String userId;
  final String requestingUserId;
  final String programId;
  final String bulan;
  final String tahun;
  final String currentUserRole;

  GetDetailPresensiParams({
    required this.userId,
    required this.requestingUserId,
    required this.programId,
    required this.bulan,
    required this.tahun,
    required this.currentUserRole,
  });
}
