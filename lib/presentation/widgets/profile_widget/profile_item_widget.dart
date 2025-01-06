import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../misc/constants.dart';

Widget profileItem(
  String title, {
  IconData? icon,
  VoidCallback? onTap,
}) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 24,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.neutral800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral600,
            ),
          ],
        ),
      ),
    );
