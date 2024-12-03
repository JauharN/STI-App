import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/presensi/detail_presensi.dart';
import '../../../domain/entities/presensi/presensi_status.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/presensi/presensi_detail_provider.dart';

class PresensiDetailPage extends ConsumerWidget {
  final String programId;

  const PresensiDetailPage({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presensiAsync = ref.watch(presensiDetailStateProvider(programId));
    final programNameAsync = ref.watch(programNameProvider(programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: presensiAsync.when(
        data: (DetailPresensi presensi) => CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgramInfo(
                      programName: programNameAsync.valueOrNull ?? 'Loading...',
                      kelas: presensi.kelas,
                      pengajar: presensi.pengajarName,
                    ),
                    verticalSpace(24),
                    _buildStatisticsCard(presensi),
                    verticalSpace(24),
                    Text(
                      'Daftar Kehadiran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    verticalSpace(16),
                    _buildPertemuanGrid(presensi.pertemuan),
                    verticalSpace(24),
                    _buildStatusLegend(),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              verticalSpace(16),
              Text(
                'Error: ${error.toString()}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(24),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(presensiDetailStateProvider(programId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Detail Presensi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgramInfo({
    required String programName,
    required String kelas,
    required String pengajar,
  }) {
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
        children: [
          _buildInfoRow('Program', programName),
          const Divider(height: 16),
          _buildInfoRow('Kelas', kelas),
          const Divider(height: 16),
          _buildInfoRow('Pengajar', pengajar),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
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
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(DetailPresensi presensi) {
    final totalPertemuan = presensi.pertemuan.length;
    final hadir = presensi.pertemuan
        .where((p) => p.status == PresensiStatus.hadir)
        .length;
    final persentase = (hadir / totalPertemuan * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Kehadiran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    '$hadir dari $totalPertemuan Pertemuan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$persentase%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(16),
          _buildDetailStatistics(presensi),
        ],
      ),
    );
  }

  Widget _buildDetailStatistics(DetailPresensi presensi) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Sakit',
          presensi.pertemuan
              .where((p) => p.status == PresensiStatus.sakit)
              .length,
          AppColors.warning,
        ),
        _buildStatItem(
          'Izin',
          presensi.pertemuan
              .where((p) => p.status == PresensiStatus.izin)
              .length,
          Colors.blue,
        ),
        _buildStatItem(
          'Alpha',
          presensi.pertemuan
              .where((p) => p.status == PresensiStatus.alpha)
              .length,
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        verticalSpace(8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildPertemuanGrid(List<PresensiDetailItem> pertemuan) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: pertemuan.map((item) {
        return _buildPertemuanItem(
          number: item.pertemuanKe,
          status: item.status,
        );
      }).toList(),
    );
  }

  Widget _buildPertemuanItem({
    required int number,
    required PresensiStatus status,
  }) {
    Color backgroundColor;
    switch (status) {
      case PresensiStatus.hadir:
        backgroundColor = const Color(0xFFE8F5E9);
      case PresensiStatus.sakit:
        backgroundColor = const Color(0xFFFFF3E0);
      case PresensiStatus.izin:
        backgroundColor = const Color(0xFFE3F2FD);
      case PresensiStatus.alpha:
        backgroundColor = const Color(0xFFFFEBEE);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == PresensiStatus.hadir
              ? AppColors.success
              : status == PresensiStatus.sakit
                  ? AppColors.warning
                  : status == PresensiStatus.izin
                      ? Colors.blue
                      : AppColors.error,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keterangan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        verticalSpace(12),
        _buildLegendItem(
          color: const Color(0xFFE8F5E9),
          borderColor: AppColors.success,
          label: 'Hadir',
        ),
        verticalSpace(8),
        _buildLegendItem(
          color: const Color(0xFFFFF3E0),
          borderColor: AppColors.warning,
          label: 'Sakit',
        ),
        verticalSpace(8),
        _buildLegendItem(
          color: const Color(0xFFE3F2FD),
          borderColor: Colors.blue,
          label: 'Izin',
        ),
        verticalSpace(8),
        _buildLegendItem(
          color: const Color(0xFFFFEBEE),
          borderColor: AppColors.error,
          label: 'Alpha',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        horizontalSpace(12),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }
}
