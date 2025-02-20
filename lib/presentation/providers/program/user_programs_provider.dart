import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/result.dart';
import '../repositories/program_repository/program_repository_provider.dart';
import '../user_data/user_data_provider.dart';

part 'user_programs_provider.g.dart';

@riverpod
class UserProgramsController extends _$UserProgramsController {
  @override
  Future<List<Program>> build() async {
    final user = ref.watch(userDataProvider).value;
    if (user == null) return [];

    final repository = ref.watch(programRepositoryProvider);
    final result = await repository.getProgramsByUserId(user.uid);

    return switch (result) {
      Success(value: final programs) => programs,
      Failed(:final message) => throw Exception(message),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  List<Program> filterActivePrograms() {
    return state.valueOrNull
            ?.where((program) =>
                program.totalPertemuan != null && program.totalPertemuan! > 0)
            .toList() ??
        [];
  }

  // Filter programs berdasarkan peran
  List<Program> getProgramsByRole(String role) {
    if (role == 'santri') {
      return filterActivePrograms();
    }
    return state.valueOrNull ?? [];
  }

  // Get programs dimana user adalah pengajar
  List<Program> getProgramsAsTeacher(String userId) {
    return state.valueOrNull
            ?.where((program) => program.pengajarIds.contains(userId))
            .toList() ??
        [];
  }

  // Check apakah user terdaftar di program
  bool isUserEnrolled(String programId) {
    return state.valueOrNull?.any((program) => program.id == programId) ??
        false;
  }

  // Check apakah user adalah pengajar di program
  bool isUserTeacher(String programId, String userId) {
    return state.valueOrNull?.any((program) =>
            program.id == programId && program.pengajarIds.contains(userId)) ??
        false;
  }
}
