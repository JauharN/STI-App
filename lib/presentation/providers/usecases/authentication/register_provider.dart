import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/authentication/register/register.dart';
import 'package:sti_app/presentation/providers/repositories/authentication_repository/authentication_provider.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

part 'register_provider.g.dart';

@riverpod
Register register(RegisterRef ref) => Register(
    authentication: ref.watch(authenticationProvider),
    userRepository: ref.watch(userRepositoryProvider));
