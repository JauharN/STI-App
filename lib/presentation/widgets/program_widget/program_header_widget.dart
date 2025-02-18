import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';

import '../../../domain/entities/presensi/program_detail.dart';

class ProgramHeaderWidget extends ConsumerWidget {
  final ProgramDetail program;
  final bool isAdmin;

  const ProgramHeaderWidget({
    super.key,
    required this.program,
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
          // Title & Edit Button
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
                IconButton(
                  onPressed: () {
                    if (isAdmin) {
                      context.showSnackBar('Edit Program akan segera hadir');
                      // TODO: Implement navigation when page is ready
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Grid
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.calendar_month,
                title: 'Total Pertemuan',
                value: program.totalMeetings.toString(),
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                icon: Icons.people,
                title: 'Santri Terdaftar',
                value: program.enrolledSantriIds.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule & Location
          if (program.schedule.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.schedule,
              title: 'Jadwal',
              value: program.schedule.join(', '),
            ),
            const SizedBox(height: 8),
          ],
          if (program.location != null && program.location!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: 'Lokasi',
              value: program.location!,
            ),
            const SizedBox(height: 8),
          ],

          // Teachers Info
          if (program.teacherIds.isNotEmpty) ...[
            _buildTeachersInfo(program.teacherNames),
            const SizedBox(height: 8),
          ] else ...[
            _buildInfoRow(
              icon: Icons.person_outline,
              title: 'Pengajar',
              value: 'Belum ditentukan',
            ),
            const SizedBox(height: 8),
          ],

          // Timestamps
          if (program.createdAt != null) ...[
            const SizedBox(height: 16),
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

  Widget _buildInfoItem({
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
    required String value,
  }) {
    return Row(
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
                value,
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

  Widget _buildTeachersInfo(List<String> teacherNames) {
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: teacherNames
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
