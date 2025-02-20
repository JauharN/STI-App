part of 'delete_program.dart';

class DeleteProgramParams {
  final String programId;
  final String currentUserRole;

  DeleteProgramParams({
    required this.programId,
    required this.currentUserRole,
  }) {
    // Basic validation
    if (programId.isEmpty) {
      throw ArgumentError('ID Program tidak boleh kosong');
    }

    // Role validation
    if (!['admin', 'superAdmin'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid untuk menghapus program');
    }
  }
}
