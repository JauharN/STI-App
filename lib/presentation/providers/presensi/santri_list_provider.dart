import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/domain/entities/result.dart';

import '../repositories/user_repository/user_repository_provider.dart';

part 'santri_list_provider.g.dart';

@riverpod
Future<List<User>> santriList(SantriListRef ref, String programId) async {
  // Get user repository instance
  final userRepository = ref.watch(userRepositoryProvider);

  try {
    // Fetch santri list by program
    final result = await userRepository.getSantriByProgramId(programId);

    // Handle result
    return switch (result) {
      Success(value: final santriList) => santriList,
      Failed(:final message) => throw Exception(message),
    };
  } catch (e) {
    throw Exception('Failed to load santri list: ${e.toString()}');
  }
}
