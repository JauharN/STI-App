import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/result.dart';
import '../repositories/user_repository/user_repository_provider.dart';

part 'available_teachers_provider.g.dart';

@riverpod
Future<List<User>> availableTeachers(AvailableTeachersRef ref) async {
  final repository = ref.read(userRepositoryProvider);

  final result = await repository.getUsersByRole(role: 'teacher');

  return switch (result) {
    Success(value: final teachers) => teachers,
    Failed(:final message) => throw Exception(message),
  };
}
