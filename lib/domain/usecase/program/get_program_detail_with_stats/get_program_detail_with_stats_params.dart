part of 'get_program_detail_with_stats.dart';

class GetProgramDetailWithStatsParams {
  final String programId;
  final String requestingUserId;
  final String currentUserRole;

  GetProgramDetailWithStatsParams({
    required this.programId,
    required this.requestingUserId,
    required this.currentUserRole,
  });
}
