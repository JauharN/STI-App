import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/misc/constants.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;

  const EmptyState({
    this.message = 'No users found',
    this.icon = Icons.group_off,
    this.iconColor = AppColors.neutral600,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
