import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../misc/constants.dart';

class STIBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final String role;
  final bool isAdmin;

  const STIBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.role,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              0,
              'Beranda',
              Icons.home_rounded,
            ),
            // Tampilkan Presensi hanya untuk non-admin
            if (!isAdmin)
              _buildNavItem(
                1,
                'Presensi',
                Icons.fact_check_rounded,
              ),
            _buildNavItem(
              2,
              'Progres',
              Icons.trending_up_rounded,
            ),
            _buildNavItem(
              3,
              'Profil',
              Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
