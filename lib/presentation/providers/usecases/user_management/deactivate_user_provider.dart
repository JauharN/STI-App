import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

import '../../../../domain/entities/user_management/deactivate_user.dart';

part 'deactivate_user_provider.g.dart';

@riverpod
DeactivateUser deactivateUser(DeactivateUserRef ref) => DeactivateUser(
      userRepository: ref.watch(userRepositoryProvider),
    );
