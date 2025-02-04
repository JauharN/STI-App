part of 'get_programs_by_user_id.dart';

class GetProgramsByUserIdParams {
  final String userId;
  final String requestingUserId;
  final String currentUserRole;

  GetProgramsByUserIdParams({
    required this.userId,
    required this.requestingUserId,
    required this.currentUserRole,
  });
}
