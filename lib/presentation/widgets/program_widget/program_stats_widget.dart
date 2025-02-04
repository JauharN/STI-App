import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgramStatsWidget extends ConsumerWidget {
  final PresensiSummary summary;
  final bool isAdmin;

  const ProgramStatsWidget({
    super.key,
    required this.summary,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik Kehadiran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  color: AppColors.primary,
                  onPressed: () {
                    // TODO: Navigate to detailed stats
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall attendance percentage
          _buildOverallStats(),

          const SizedBox(height: 24),

          // Status breakdown
          _buildStatusGrid(),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Kehadiran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.hadir} dari ${summary.totalSantri}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '${summary.persentaseKehadiran.toStringAsFixed(1)}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          'Sakit',
          summary.sakit,
          summary.persentaseSakit,
          AppColors.warning,
          Icons.sick_outlined,
        ),
        _buildStatusCard(
          'Izin',
          summary.izin,
          summary.persentaseIzin,
          Colors.blue,
          Icons.event_busy_outlined,
        ),
        _buildStatusCard(
          'Alpha',
          summary.alpha,
          summary.persentaseAlpha,
          AppColors.error,
          Icons.cancel_outlined,
        ),
        _buildStatusCard(
          'Total',
          summary.totalSantri,
          100.0,
          AppColors.neutral600,
          Icons.groups_outlined,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    int count,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            '$count Santri',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
