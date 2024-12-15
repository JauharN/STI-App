import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/result.dart';
import '../repositories/program_repository/program_repository_provider.dart';

part 'available_programs_provider.g.dart';

@riverpod
Future<List<Program>> availablePrograms(AvailableProgramsRef ref) async {
  final repository = ref.read(programRepositoryProvider);
  final result = await repository.getAllPrograms();

  return switch (result) {
    Success(value: final programs) => programs,
    Failed(:final message) => throw Exception(message),
  };
}
