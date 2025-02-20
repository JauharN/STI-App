import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/presensi/program_detail.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';

class ProgramDetailCard extends ConsumerWidget {
  final ProgramDetail program;
  final bool isAdmin;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProgramDetailCard({
    super.key,
    required this.program,
    required this.isAdmin,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
          // Title & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.neutral600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit Program'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            'Hapus Program',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Program Stats Grid
          Row(
            children: [
              _buildStatItem(
                icon: Icons.calendar_month,
                title: 'Total Pertemuan',
                value: program.totalMeetings.toString(),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.people,
                title: 'Santri Terdaftar',
                value: program.enrolledSantriIds.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule Section
          if (program.schedule.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.schedule,
              title: 'Jadwal',
              content: program.schedule.join(', '),
            ),
            const SizedBox(height: 12),
          ],

          // Location Section
          if (program.location != null && program.location!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: 'Lokasi',
              content: program.location!,
            ),
            const SizedBox(height: 12),
          ],

          // Teachers Section
          _buildTeachersSection(),
          const SizedBox(height: 12),

          // Timestamps
          if (program.createdAt != null) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${formatDateTime(program.createdAt!)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
            if (program.updatedAt != null)
              Text(
                'Diperbarui: ${formatDateTime(program.updatedAt!)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neutral600, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.neutral800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.people_outline, color: AppColors.neutral600, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengajar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 4),
              if (program.teacherNames.isEmpty)
                Text(
                  'Belum ada pengajar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.neutral600,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: program.teacherNames
                      .map((name) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
