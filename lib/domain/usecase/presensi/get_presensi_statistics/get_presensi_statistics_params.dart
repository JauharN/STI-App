part of 'get_presensi_statistics.dart';

class GetPresensiStatisticsParams {
  final String programId;
  final DateTime? startDate;
  final DateTime? endDate;
  final UserRole currentUserRole;

  GetPresensiStatisticsParams({
    required this.programId,
    this.startDate,
    this.endDate,
    required this.currentUserRole,
  });
}
