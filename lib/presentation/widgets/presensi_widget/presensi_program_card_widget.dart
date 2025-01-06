import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/presensi/presensi_summary.dart';
import '../../../domain/entities/result.dart';
import '../../misc/constants.dart';
import '../../providers/repositories/presensi_repository/presensi_repository_provider.dart';

class PresensiProgramCard extends ConsumerWidget {
  final String title;
  final String userId;
  final String programId;
  final VoidCallback onTap;

  const PresensiProgramCard({
    super.key,
    required this.title,
    required this.userId,
    required this.programId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presensiResult =
        ref.watch(presensiRepositoryProvider).getPresensiSummary(
              userId: userId,
              programId: programId,
            );

    return FutureBuilder<Result<PresensiSummary>>(
      future: presensiResult,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            title: title,
            summary: 'Loading...',
            onTap: onTap,
          );
        }

        // Error State
        if (snapshot.hasError) {
          return _buildCard(
            title: title,
            summary: 'Error: ${snapshot.error}',
            onTap: onTap,
          );
        }

        // Success State
        if (snapshot.hasData) {
          return switch (snapshot.data!) {
            Success(value: final summary) => _buildCard(
                title: title,
                summary: 'Hadir ${summary.hadir} - Sakit ${summary.sakit} - '
                    'Izin ${summary.izin} - Alpha ${summary.alpha}',
                onTap: onTap,
              ),
            Failed(:final message) => _buildCard(
                title: title,
                summary: 'Error: $message',
                onTap: onTap,
              ),
          };
        }

        return _buildCard(
          title: title,
          summary: 'No data',
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String summary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
