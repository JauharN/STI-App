import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/authentication/reset_password/reset_password.dart';
import '../../repositories/user_repository/user_repository_provider.dart';

part 'reset_password_provider.g.dart';

@riverpod
ResetPassword resetPassword(ResetPasswordRef ref) =>
    ResetPassword(userRepository: ref.watch(userRepositoryProvider));
