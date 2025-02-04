part of 'get_presensi_statistics.dart';

class GetPresensiStatisticsParams {
  final String programId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currentUserRole;

  GetPresensiStatisticsParams({
    required this.programId,
    required this.currentUserRole,
    this.startDate,
    this.endDate,
  });
}
