part of 'get_program_by_id.dart';

class GetProgramByIdParams {
  final String programId;
  final String currentUserRole;

  GetProgramByIdParams({
    required this.programId,
    required this.currentUserRole,
  }) {
    // Validasi input
    if (programId.isEmpty) {
      throw ArgumentError('ID program tidak boleh kosong');
    }

    // Validasi role
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }
  }
}
