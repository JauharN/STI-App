part of 'get_santri_by_program.dart';

class GetSantriByProgramParams {
  final String programId;
  final UserRole currentUserRole;

  GetSantriByProgramParams({
    required this.programId,
    required this.currentUserRole,
  });
}
