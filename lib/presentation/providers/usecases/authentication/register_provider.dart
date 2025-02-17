import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/authentication/register/register.dart';
import '../../repositories/authentication_repository/authentication_provider.dart';
import '../../repositories/program_repository/program_repository_provider.dart';
import '../../repositories/user_repository/user_repository_provider.dart';

part 'register_provider.g.dart';

@riverpod
Register register(RegisterRef ref) => Register(
      authentication: ref.watch(authenticationProvider),
      userRepository: ref.watch(userRepositoryProvider),
      programRepository: ref.watch(programRepositoryProvider),
    );
