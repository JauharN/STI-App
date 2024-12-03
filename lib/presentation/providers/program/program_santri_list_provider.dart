// presentation/providers/program/program_santri_list_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecase/santri/get_santri_by_program.dart';
import '../usecases/santri/get_santri_by_program_provider.dart';

part 'program_santri_list_provider.g.dart';

@riverpod
Future<List<User>> programSantriList(
  ProgramSantriListRef ref,
  String programId,
) async {
  // Get santri list dari use case
  final result = await ref.read(getSantriByProgramProvider).call(
        GetSantriByProgramParams(programId: programId),
      );

  // Handle hasil
  return switch (result) {
    Success(value: final list) => list,
    Failed(:final message) => throw Exception(message),
  };
}
