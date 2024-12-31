part of 'update_user_role.dart';

class UpdateUserRoleParams {
  final String uid;
  final UserRole newRole;
  final UserRole currentUserRole;

  UpdateUserRoleParams({
    required this.uid,
    required this.newRole,
    required this.currentUserRole,
  });
}
