import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';

class ProgresHafalanListItem extends StatelessWidget {
  final ProgresHafalan progres;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const ProgresHafalanListItem({
    super.key,
    required this.progres,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      formatDate(progres.tanggal),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Content based on program type
              if (progres.programId == 'TAHFIDZ') ...[
                _buildTahfidzContent(),
              ] else ...[
                _buildGMMContent(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTahfidzContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Juz ${progres.juz}, Halaman ${progres.halaman}, Ayat ${progres.ayat}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Surah: ${progres.surah}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(
          progres.statusPenilaian ?? '-',
          _getStatusColor(progres.statusPenilaian),
        ),
      ],
    );
  }

  Widget _buildGMMContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iqro Level ${progres.iqroLevel}, Halaman ${progres.iqroHalaman}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Target: ${progres.mutabaahTarget}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusBadge(
              'Iqro: ${progres.statusIqro ?? "-"}',
              _getStatusColor(progres.statusIqro),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(
              'Mutabaah: ${progres.statusMutabaah ?? "-"}',
              _getMutabaahStatusColor(progres.statusMutabaah),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
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

  Color _getStatusColor(String? status) {
    return switch (status) {
      'Lancar' => AppColors.success,
      'Belum' => AppColors.warning,
      'Perlu Perbaikan' => AppColors.error,
      _ => AppColors.neutral400,
    };
  }

  Color _getMutabaahStatusColor(String? status) {
    return switch (status) {
      'Tercapai' => AppColors.success,
      'Belum' => AppColors.warning,
      _ => AppColors.neutral400,
    };
  }
}
