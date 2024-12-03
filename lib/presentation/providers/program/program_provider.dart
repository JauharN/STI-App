import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/program.dart';
import '../../../domain/entities/result.dart';
import '../repositories/program_repository/program_repository_provider.dart';

part 'program_provider.g.dart';

@riverpod
Future<Program> program(ProgramRef ref, String programId) async {
  final programRepository = ref.watch(programRepositoryProvider);
  final result = await programRepository.getProgramById(programId);

  return switch (result) {
    Success(value: final program) => program,
    Failed(:final message) => throw Exception(message),
  };
}
