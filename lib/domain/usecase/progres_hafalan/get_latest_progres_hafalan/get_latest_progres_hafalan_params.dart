part of 'get_latest_progres_hafalan.dart';

class GetLatestProgresHafalanParams {
  final String userId;
  final String requestingUserId;
  final String currentUserRole;

  GetLatestProgresHafalanParams({
    required this.userId,
    required this.requestingUserId,
    required this.currentUserRole,
  }) {
    // Validasi ID santri
    if (userId.isEmpty) {
      throw ArgumentError('ID santri tidak boleh kosong');
    }

    // Validasi ID requester
    if (requestingUserId.isEmpty) {
      throw ArgumentError('ID requester tidak boleh kosong');
    }

    // Validasi role
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }
  }
}
