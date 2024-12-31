import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/user.dart';
import '../../misc/constants.dart';

class RoleBadgeWidget extends StatelessWidget {
  final UserRole role;

  const RoleBadgeWidget({
    super.key,
    required this.role,
  });

  Color get _backgroundColor {
    return switch (role) {
      UserRole.superAdmin => AppColors.error.withOpacity(0.1),
      UserRole.admin => AppColors.primary.withOpacity(0.1),
      UserRole.santri => AppColors.secondary.withOpacity(0.1),
    };
  }

  Color get _textColor {
    return switch (role) {
      UserRole.superAdmin => AppColors.error,
      UserRole.admin => AppColors.primary,
      UserRole.santri => AppColors.secondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: _textColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        role.displayName,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
