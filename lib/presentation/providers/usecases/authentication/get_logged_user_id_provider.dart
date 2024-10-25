import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/authentication/getLoggedUserId/get_logged_user_id.dart';
import 'package:sti_app/presentation/providers/repositories/authentication/authentication_provider.dart';
import 'package:sti_app/presentation/providers/repositories/user_repository/user_repository_provider.dart';

part 'get_logged_user_id_provider.g.dart';

@riverpod
GetLoggedUserId getLoggedUserId(GetLoggedUserIdRef ref) => GetLoggedUserId(
    authentication: ref.watch(authenticationProvider),
    userRepository: ref.watch(userRepositoryProvider));
