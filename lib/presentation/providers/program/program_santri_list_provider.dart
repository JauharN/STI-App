import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecase/santri/get_santri_by_program.dart';
import '../usecases/santri/get_santri_by_program_provider.dart';
import '../user_data/user_data_provider.dart';

part 'program_santri_list_provider.g.dart';

@riverpod
Future<List<User>> programSantriList(
  ProgramSantriListRef ref,
  String programId,
) async {
  final user = ref.read(userDataProvider).value;
  if (user == null) {
    throw Exception('User tidak ditemukan');
  }

  // Role validation dengan string
  final currentUserRole = user.role;

  final result = await ref.read(getSantriByProgramProvider).call(
        GetSantriByProgramParams(
          programId: programId,
          currentUserRole: currentUserRole,
        ),
      );

  return switch (result) {
    Success(value: final list) => list,
    Failed(:final message) => throw Exception(message),
  };
}
