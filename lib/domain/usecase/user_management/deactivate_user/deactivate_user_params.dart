part of 'deactivate_user.dart';

class DeactivateUserParams {
  final String uid;
  final UserRole currentUserRole;

  DeactivateUserParams({
    required this.uid,
    required this.currentUserRole,
  });
}
