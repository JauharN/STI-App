import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/authentication/login/login.dart';
import 'package:sti_app/presentation/providers/repositories/authentication_repository/authentication_provider.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

part 'login_provider.g.dart';

@riverpod
Login login(LoginRef ref) => Login(
      authentication: ref.watch(authenticationProvider),
      userRepository: ref.watch(userRepositoryProvider),
    );
