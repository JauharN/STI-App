import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../misc/constants.dart';

class RoleBadgeWidget extends StatelessWidget {
  final String role;

  const RoleBadgeWidget({
    super.key,
    required this.role,
  });

  Color get _backgroundColor {
    return switch (role) {
      'superAdmin' => AppColors.error.withOpacity(0.1),
      'admin' => AppColors.primary.withOpacity(0.1),
      'santri' => AppColors.secondary.withOpacity(0.1),
      _ => AppColors.neutral300.withOpacity(0.1),
    };
  }

  Color get _textColor {
    return switch (role) {
      'superAdmin' => AppColors.error,
      'admin' => AppColors.primary,
      'santri' => AppColors.secondary,
      _ => AppColors.neutral600,
    };
  }

  String get _displayName {
    return switch (role) {
      'superAdmin' => 'Super Admin',
      'admin' => 'Admin',
      'santri' => 'Santri',
      _ => 'Unknown Role',
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
        _displayName,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
