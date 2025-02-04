import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../misc/constants.dart';

class ProgramActionWidget extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onInputPresensi;
  final VoidCallback? onManagePresensi;
  final VoidCallback? onViewStatistics;
  final VoidCallback? onExportData;

  const ProgramActionWidget({
    super.key,
    required this.isAdmin,
    this.onInputPresensi,
    this.onManagePresensi,
    this.onViewStatistics,
    this.onExportData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 16),
          if (isAdmin) ...[
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Input Presensi',
              color: AppColors.primary,
              onTap: onInputPresensi,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.edit_outlined,
              label: 'Kelola Presensi',
              color: AppColors.secondary,
              onTap: onManagePresensi,
            ),
          ],
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.analytics_outlined,
            label: 'Lihat Statistik',
            color: Colors.blue,
            onTap: onViewStatistics,
          ),
          if (isAdmin) ...[
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.download_outlined,
              label: 'Export Data',
              color: Colors.green,
              onTap: onExportData,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
