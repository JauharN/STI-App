part of 'get_program_detail_with_stats.dart';

class GetProgramDetailWithStatsParams {
  final String programId;
  final String requestingUserId;
  final String currentUserRole;

  GetProgramDetailWithStatsParams({
    required this.programId,
    required this.requestingUserId,
    required this.currentUserRole,
  }) {
    // Validasi input
    if (programId.isEmpty) {
      throw ArgumentError('ID program tidak boleh kosong');
    }
    if (requestingUserId.isEmpty) {
      throw ArgumentError('ID user tidak boleh kosong');
    }
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }
  }
}
