import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user.dart';
import '../repositories/user_repository/user_repository_provider.dart';
import '../program/program_provider.dart';

part 'enrolled_santri_provider.g.dart';

@riverpod
Future<List<User>> enrolledSantri(
  EnrolledSantriRef ref,
  String programId,
) async {
  final repository = ref.read(userRepositoryProvider);
  final program = await ref.watch(programProvider(programId).future);

  if (program.enrolledSantriIds.isEmpty) {
    return [];
  }

  final userResults = await Future.wait(
    program.enrolledSantriIds.map(
      (id) => repository.getUser(uid: id),
    ),
  );

  // Filter out failed results and map to User objects
  final santriList = userResults
      .where((result) => result.isSuccess)
      .map((result) => result.resultValue!)
      .toList();

  return santriList;
}
