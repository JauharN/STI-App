part of 'get_presensi_summary.dart';

class GetPresensiSummaryParams {
  final String userId;
  final String requestingUserId;
  final String programId;
  final String currentUserRole;

  GetPresensiSummaryParams({
    required this.userId,
    required this.requestingUserId,
    required this.programId,
    required this.currentUserRole,
  });
}
