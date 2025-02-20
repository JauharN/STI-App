import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/result.dart';
import '../repositories/program_repository/program_repository_provider.dart';

part 'available_programs_provider.g.dart';

@riverpod
class AvailableProgramsState extends _$AvailableProgramsState {
  @override
  Future<List<Program>> build() async {
    final repository = ref.read(programRepositoryProvider);
    final result = await repository.getAllPrograms();

    return switch (result) {
      Success(value: final programs) => _sortPrograms(programs),
      Failed(:final message) => throw Exception(message),
    };
  }

  List<Program> _sortPrograms(List<Program> programs) {
    // Sort berdasarkan prioritas
    final defaultPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];

    return programs
      ..sort((a, b) {
        // 1. Program default di atas
        final aIsDefault = defaultPrograms.contains(a.nama);
        final bIsDefault = defaultPrograms.contains(b.nama);

        if (aIsDefault && !bIsDefault) return -1;
        if (!aIsDefault && bIsDefault) return 1;

        // 2. Urutan spesifik untuk program default
        if (aIsDefault && bIsDefault) {
          return defaultPrograms
              .indexOf(a.nama)
              .compareTo(defaultPrograms.indexOf(b.nama));
        }

        // 3. Non-default programs sort by nama
        return a.nama.compareTo(b.nama);
      });
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  List<Program> getActivePrograms() {
    return state.valueOrNull
            ?.where((program) =>
                program.totalPertemuan != null && program.totalPertemuan! > 0)
            .toList() ??
        [];
  }

  List<Program> getProgramsByTeacher(String teacherId) {
    return state.valueOrNull
            ?.where((program) => program.pengajarIds.contains(teacherId))
            .toList() ??
        [];
  }
}
