import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

part 'available_santri_provider.g.dart';

@riverpod
Future<List<User>> availableSantri(AvailableSantriRef ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUsersByRole(role: 'santri');

  if (result.isSuccess) {
    return result.resultValue!;
  } else {
    throw result.errorMessage!;
  }
}
