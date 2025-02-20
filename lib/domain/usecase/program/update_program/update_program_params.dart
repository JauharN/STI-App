part of 'update_program.dart';

class UpdateProgramParams {
  final Program program;
  final String currentUserRole;

  UpdateProgramParams({
    required this.program,
    required this.currentUserRole,
  }) {
    // Basic validation
    if (!['admin', 'superAdmin'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid untuk memperbarui program');
    }

    // Program validation
    if (program.jadwal.isEmpty || program.nama.isEmpty) {
      throw ArgumentError('Data program tidak lengkap');
    }

    // Teacher validation
    if (program.pengajarIds.length != program.pengajarNames.length) {
      throw ArgumentError('Data pengajar tidak valid');
    }
  }
}
