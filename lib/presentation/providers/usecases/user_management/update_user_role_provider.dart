import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

import '../../../../domain/usecase/user_management/update_user_role/update_user_role.dart';

part 'update_user_role_provider.g.dart';

@riverpod
UpdateUserRole updateUserRole(UpdateUserRoleRef ref) => UpdateUserRole(
      userRepository: ref.watch(userRepositoryProvider),
    );
