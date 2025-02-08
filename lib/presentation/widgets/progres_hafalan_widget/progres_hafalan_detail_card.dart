import 'package:flutter/material.dart';

import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';

class ProgresHafalanDetailCard extends StatelessWidget {
  final ProgresHafalan progres;
  final VoidCallback? onEdit;
  final bool isAdmin;

  const ProgresHafalanDetailCard({
    super.key,
    required this.progres,
    this.onEdit,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progres.programId == 'TAHFIDZ'
                      ? 'Detail Tahfidz'
                      : 'Detail GMM',
                  style: AppTextStyles.h3,
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.primary,
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tanggal
            _buildInfoRow(
              'Tanggal',
              formatDate(progres.tanggal),
            ),
            const SizedBox(height: 16),

            // Content based on program
            if (progres.programId == 'TAHFIDZ')
              _buildTahfidzDetail()
            else
              _buildGMMDetail(),

            const SizedBox(height: 16),

            // Catatan
            if (progres.catatan?.isNotEmpty ?? false) ...[
              Text(
                'Catatan:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progres.catatan!,
                style: AppTextStyles.bodyMedium,
              ),
            ],

            // Timestamps
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (progres.createdAt != null)
              Text(
                'Dibuat: ${formatDateTime(progres.createdAt!)}',
                style: AppTextStyles.caption,
              ),
            if (progres.updatedAt != null)
              Text(
                'Diperbarui: ${formatDateTime(progres.updatedAt!)}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTahfidzDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Juz', progres.juz?.toString() ?? '-'),
        const SizedBox(height: 8),
        _buildInfoRow('Halaman', progres.halaman?.toString() ?? '-'),
        const SizedBox(height: 8),
        _buildInfoRow('Ayat', progres.ayat?.toString() ?? '-'),
        const SizedBox(height: 8),
        _buildInfoRow('Surah', progres.surah ?? '-'),
        const SizedBox(height: 8),
        _buildStatusRow('Status Penilaian', progres.statusPenilaian ?? '-'),
      ],
    );
  }

  Widget _buildGMMDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Level Iqro', progres.iqroLevel ?? '-'),
        const SizedBox(height: 8),
        _buildInfoRow('Halaman', progres.iqroHalaman?.toString() ?? '-'),
        const SizedBox(height: 8),
        _buildStatusRow('Status Iqro', progres.statusIqro ?? '-'),
        const SizedBox(height: 8),
        _buildInfoRow('Target Mutabaah', progres.mutabaahTarget ?? '-'),
        const SizedBox(height: 8),
        _buildStatusRow('Status Mutabaah', progres.statusMutabaah ?? '-'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _getStatusColor(status).withOpacity(0.2),
              ),
            ),
            child: Text(
              status,
              style: AppTextStyles.bodySmall.copyWith(
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'Lancar' || 'Tercapai' => AppColors.success,
      'Belum' => AppColors.warning,
      'Perlu Perbaikan' => AppColors.error,
      _ => AppColors.neutral400,
    };
  }
}
