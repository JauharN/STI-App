import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

import '../../../../domain/entities/result.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/user_management/get_users_by_role.dart';

part 'get_users_by_role_provider.g.dart';

// Provider untuk usecase
@riverpod
GetUsersByRole getUsersByRoleUsecase(GetUsersByRoleUsecaseRef ref) =>
    GetUsersByRole(
      userRepository: ref.watch(userRepositoryProvider),
    );

@riverpod
Future<List<User>> getUsersByRole(
  GetUsersByRoleRef ref, {
  required UserRole roleToGet,
  required UserRole currentUserRole,
  required bool includeInactive,
}) async {
  final usecase = ref.watch(getUsersByRoleUsecaseProvider);
  final params = GetUsersByRoleParams(
    roleToGet: roleToGet,
    currentUserRole: currentUserRole,
    includeInactive: includeInactive,
  );

  final result = await usecase(params);
  return switch (result) {
    Success(value: final users) => users,
    Failed(:final message) => throw Exception(message),
  };
}
