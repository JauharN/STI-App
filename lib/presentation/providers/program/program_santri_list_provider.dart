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
  // Ambil role pengguna saat ini
  final currentUserRole = ref.read(userDataProvider).value?.role;
  if (currentUserRole == null) {
    throw Exception('User role is not available');
  }

  // Get santri list dari use case
  final result = await ref.read(getSantriByProgramProvider).call(
        GetSantriByProgramParams(
          programId: programId,
          currentUserRole: currentUserRole, // Tambahkan parameter role
        ),
      );

  // Handle hasil
  return switch (result) {
    Success(value: final list) => list,
    Failed(:final message) => throw Exception(message),
  };
}
