import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecase/santri/get_santri_by_program.dart';
import '../usecases/santri/get_santri_by_program_provider.dart';
import '../user_data/user_data_provider.dart';

part 'program_santri_list_provider.g.dart';

@riverpod
class ProgramSantriList extends _$ProgramSantriList {
  @override
  Future<List<User>> build(String programId) async {
    final user = ref.read(userDataProvider).value;
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    // Role validation
    if (user.role != 'admin' && user.role != 'superAdmin') {
      if (!user.hasProgram(programId)) {
        throw Exception('Anda tidak memiliki akses ke program ini');
      }
    }

    final result = await ref.read(getSantriByProgramProvider).call(
          GetSantriByProgramParams(
            programId: programId,
            currentUserRole: user.role,
          ),
        );

    return switch (result) {
      Success(value: final list) => list,
      Failed(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
