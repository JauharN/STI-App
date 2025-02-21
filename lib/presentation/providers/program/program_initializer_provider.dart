import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/initializer/program_initializer.dart';
import '../repositories/program_repository/program_repository_provider.dart';
import '../usecases/program/create_program_provider.dart';

part 'program_initializer_provider.g.dart';

@riverpod
ProgramInitializer programInitializer(ProgramInitializerRef ref) {
  return ProgramInitializer(
    createProgram: ref.watch(createProgramProvider),
    programRepository: ref.watch(programRepositoryProvider),
  );
}

// State provider untuk tracking status inisialisasi
@riverpod
class ProgramInitializationState extends _$ProgramInitializationState {
  @override
  bool build() => false;

  Future<void> initialize() async {
    if (state) return; // Skip jika sudah terinisialisasi

    try {
      await ref.read(programInitializerProvider).initializeDefaultPrograms();
      state = true;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  void reset() {
    state = false;
  }
}
