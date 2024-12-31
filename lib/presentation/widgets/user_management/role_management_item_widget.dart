import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/widgets/user_management/role_badge_widget.dart';

class RoleManagementItemWidget extends StatelessWidget {
  final User user;
  final Function(UserRole) onUpdateRole;
  final VoidCallback onToggleActive;

  const RoleManagementItemWidget({
    required this.user,
    required this.onUpdateRole,
    required this.onToggleActive,
    super.key,
  });

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current role: ${user.role.displayName}'),
            const SizedBox(height: 16),
            ...UserRole.values.where((role) => role != UserRole.superAdmin).map(
                  (role) => ListTile(
                    title: Text(role.displayName),
                    leading: role == user.role
                        ? const Icon(Icons.check, color: AppColors.success)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onUpdateRole(role);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : const AssetImage('assets/profile-placeholder.png')
                  as ImageProvider,
        ),
        title: Text(
          user.name,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoleBadgeWidget(role: user.role),
            const SizedBox(width: 8),
            if (!user.isActive) const Icon(Icons.block, color: AppColors.error),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showActionMenu(context),
            ),
          ],
        ),
        onTap: () => _showRoleDialog(context),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Change Role'),
            onTap: () {
              Navigator.pop(context);
              _showRoleDialog(context);
            },
          ),
          ListTile(
            leading: Icon(
              user.isActive ? Icons.block : Icons.check_circle,
              color: user.isActive ? AppColors.error : AppColors.success,
            ),
            title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
            onTap: () {
              Navigator.pop(context);
              onToggleActive();
            },
          ),
        ],
      ),
    );
  }
}
