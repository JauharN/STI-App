part of 'update_program.dart';

class UpdateProgramParams {
  // Program yang akan diupdate
  final Program program;
  final UserRole currentUserRole;

  UpdateProgramParams({
    required this.program,
    required this.currentUserRole,
  });
}
