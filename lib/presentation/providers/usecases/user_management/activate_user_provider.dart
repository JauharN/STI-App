import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

import '../../../../domain/entities/user_management/activate_user.dart';

part 'activate_user_provider.g.dart';

@riverpod
ActivateUser activateUser(ActivateUserRef ref) => ActivateUser(
      userRepository: ref.watch(userRepositoryProvider),
    );
