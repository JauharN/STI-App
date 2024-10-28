import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../misc/constants.dart';

class STIBottomNavBarItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final String label;
  final IconData icon;

  const STIBottomNavBarItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.neutral600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
