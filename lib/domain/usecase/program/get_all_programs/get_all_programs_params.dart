part of 'get_all_programs.dart';

class GetAllProgramsParams {
  final String currentUserRole;

  GetAllProgramsParams({
    required this.currentUserRole,
  }) {
    // Validasi role
    if (!['admin', 'superAdmin', 'santri'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid');
    }
  }
}
