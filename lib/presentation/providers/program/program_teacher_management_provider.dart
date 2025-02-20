import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/program.dart';
import '../repositories/program_repository/program_repository_provider.dart';
import '../user_data/user_data_provider.dart';

part 'program_teacher_management_provider.g.dart';

@riverpod
class ProgramTeacherManagement extends _$ProgramTeacherManagement {
  @override
  Future<List<Program>> build() async {
    return [];
  }

  Future<bool> addTeacherToProgram({
    required String programId,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      // Cek user role
      final user = ref.read(userDataProvider).value;
      if (user == null || (user.role != 'admin' && user.role != 'superAdmin')) {
        throw Exception(
            'Hanya admin dan superAdmin yang dapat menambah pengajar');
      }

      final repository = ref.read(programRepositoryProvider);
      final result = await repository.addTeacherToProgram(
        programId: programId,
        teacherId: teacherId,
        teacherName: teacherName,
      );

      if (result.isSuccess) {
        // Refresh state setelah berhasil menambah pengajar
        ref.invalidateSelf();
        return true;
      }

      throw Exception(result.errorMessage ?? 'Gagal menambah pengajar');
    } catch (e) {
      throw Exception('Gagal menambah pengajar: ${e.toString()}');
    }
  }

  List<String> getTeacherIds(String programId) {
    return state.valueOrNull
            ?.firstWhere(
              (program) => program.id == programId,
              orElse: () => Program(
                id: '',
                nama: '',
                deskripsi: '',
                jadwal: [],
              ),
            )
            .pengajarIds ??
        [];
  }

  List<String> getTeacherNames(String programId) {
    return state.valueOrNull
            ?.firstWhere(
              (program) => program.id == programId,
              orElse: () => Program(
                id: '',
                nama: '',
                deskripsi: '',
                jadwal: [],
              ),
            )
            .pengajarNames ??
        [];
  }

  bool canAddMoreTeachers(String programId) {
    final program = state.valueOrNull?.firstWhere(
      (program) => program.id == programId,
      orElse: () => Program(
        id: '',
        nama: '',
        deskripsi: '',
        jadwal: [],
      ),
    );

    final currentTeachers = program?.pengajarIds.length ?? 0;
    return currentTeachers < Program.maxTeachers;
  }
}
