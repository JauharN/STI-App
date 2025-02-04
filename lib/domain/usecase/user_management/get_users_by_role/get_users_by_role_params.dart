part of 'get_users_by_role.dart';

class GetUsersByRoleParams {
  final String roleToGet;
  final String currentUserRole;
  final bool includeInactive;

  GetUsersByRoleParams({
    required this.roleToGet,
    required this.currentUserRole,
    this.includeInactive = false,
  });
}
