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

  // Method untuk refresh data
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  // Method untuk filter program
  List<Program> filterActivePrograms(List<Program> programs) {
    return programs
        .where((program) =>
            program.totalPertemuan != null && program.totalPertemuan! > 0)
        .toList();
  }
}
