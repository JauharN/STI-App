part of 'activate_user.dart';

class ActivateUserParams {
  final String uid;
  final UserRole currentUserRole;

  ActivateUserParams({
    required this.uid,
    required this.currentUserRole,
  });
}
