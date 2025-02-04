part of 'update_user_role.dart';

class UpdateUserRoleParams {
  final String uid;
  final String newRole;
  final String currentUserRole;

  UpdateUserRoleParams({
    required this.uid,
    required this.newRole,
    required this.currentUserRole,
  });
}
