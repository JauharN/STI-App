import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

import '../../../../domain/entities/result.dart';

part 'get_user_provider.g.dart';

@riverpod
Future<User> getUser(GetUserRef ref, String uid) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUser(uid: uid);

  return switch (result) {
    Success(value: final user) => user,
    Failed(:final message) => throw Exception(message),
  };
}
