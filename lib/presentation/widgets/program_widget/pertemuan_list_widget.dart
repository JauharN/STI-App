import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/presensi/detail_presensi.dart';
import '../../../domain/entities/presensi/presensi_status.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';

class PertemuanListWidget extends ConsumerWidget {
  final DetailPresensi detailPresensi;
  final bool isAdmin;
  final Function(PresensiDetailItem)? onPertemuanTap;
  final VoidCallback? onAddPertemuan;

  const PertemuanListWidget({
    super.key,
    required this.detailPresensi,
    required this.isAdmin,
    this.onPertemuanTap,
    this.onAddPertemuan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pertemuan = detailPresensi.pertemuan;

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
                'Daftar Pertemuan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              if (isAdmin && onAddPertemuan != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  onPressed: onAddPertemuan,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (pertemuan.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pertemuan.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildPertemuanItem(
                pertemuan[index],
                onTap: onPertemuanTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pertemuan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.neutral600,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              Text(
                'Klik + untuk menambah pertemuan baru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPertemuanItem(
    PresensiDetailItem pertemuan, {
    Function(PresensiDetailItem)? onTap,
  }) {
    return InkWell(
      onTap: onTap != null ? () => onTap(pertemuan) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pertemuan ${pertemuan.pertemuanKe}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    formatDate(pertemuan.tanggal),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (pertemuan.materi?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                pertemuan.materi!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            _buildStatusBadge(pertemuan.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PresensiStatus status) {
    final (color, label) = switch (status) {
      PresensiStatus.hadir => (AppColors.success, 'Hadir'),
      PresensiStatus.sakit => (AppColors.warning, 'Sakit'),
      PresensiStatus.izin => (Colors.blue, 'Izin'),
      PresensiStatus.alpha => (AppColors.error, 'Alpha'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
