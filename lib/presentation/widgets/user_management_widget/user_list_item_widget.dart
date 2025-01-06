import 'package:flutter/material.dart';
import 'package:sti_app/presentation/widgets/user_management_widget/role_badge_widget.dart';

import '../../../domain/entities/user.dart';
import '../../misc/constants.dart';

class UserListItemWidget extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserListItemWidget({
    super.key,
    required this.user,
    required this.onTap,
  });

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
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoleBadgeWidget(role: user.role),
            if (!user.isActive)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.block, color: AppColors.error),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
