part of 'add_teacher_to_program.dart';

class AddTeacherToProgramParams {
  final String programId;
  final String teacherId;
  final String teacherName;
  final String currentUserRole;

  AddTeacherToProgramParams({
    required this.programId,
    required this.teacherId,
    required this.teacherName,
    required this.currentUserRole,
  }) {
    // Validasi input
    if (programId.isEmpty) {
      throw ArgumentError('ID program tidak boleh kosong');
    }
    if (teacherId.isEmpty) {
      throw ArgumentError('ID pengajar tidak boleh kosong');
    }
    if (teacherName.isEmpty) {
      throw ArgumentError('Nama pengajar tidak boleh kosong');
    }
    if (!['admin', 'superAdmin'].contains(currentUserRole)) {
      throw ArgumentError('Role tidak valid untuk menambah pengajar');
    }
  }
}
