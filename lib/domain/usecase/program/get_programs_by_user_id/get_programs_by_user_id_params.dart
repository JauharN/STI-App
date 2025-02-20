part of 'get_programs_by_user_id.dart';

class GetProgramsByUserIdParams {
  final String userId;
  final String requestingUserId;
  final String currentUserRole;

  GetProgramsByUserIdParams({
    required this.userId,
    required this.requestingUserId,
    required this.currentUserRole,
  }) {
    // Validasi ID user
    if (userId.isEmpty) {
      throw ArgumentError('ID user tidak boleh kosong');
    }
    if (requestingUserId.isEmpty) {
      throw ArgumentError('ID requester tidak boleh kosong');
    }

    // Validasi role
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }
  }
}
