import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/presensi/detail_presensi.dart';
import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/presensi/presensi_detail_provider.dart';
import '../../providers/user_data/user_data_provider.dart';

// State Providers untuk status
final presensiStatusProvider = StateProvider<Map<int, String>>((ref) => {});

class PresensiDetailPage extends ConsumerStatefulWidget {
  final String programId;

  const PresensiDetailPage({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<PresensiDetailPage> createState() => _PresensiDetailPageState();
}

class _PresensiDetailPageState extends ConsumerState<PresensiDetailPage> {
  // Constants
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  // Access Control
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!DetailPresensi.canAccess(userRole ?? '')) {
      Navigator.pop(context);
      context.showErrorSnackBar('Anda tidak memiliki akses');
    }
  }

  // Error Handling
  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation,
  ) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation();
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
              'Operation failed after $maxRetries attempts: ${e.toString()}',
            );
          }
          return false;
        }
        await Future.delayed(retryDelay * retryCount);
      }
    }
    return false;
  }

  Future<void> _refreshData() async {
    await _handleOperationWithRetry(() async {
      await ref.refresh(presensiDetailStateProvider(widget.programId).future);
    });
  }

  // Status Helpers
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HADIR':
        return AppColors.success;
      case 'SAKIT':
        return AppColors.warning;
      case 'IZIN':
        return Colors.blue;
      case 'ALPHA':
        return AppColors.error;
      default:
        return AppColors.neutral400;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'HADIR':
        return const Color(0xFFE8F5E9);
      case 'SAKIT':
        return const Color(0xFFFFF3E0);
      case 'IZIN':
        return const Color(0xFFE3F2FD);
      case 'ALPHA':
        return const Color(0xFFFFEBEE);
      default:
        return AppColors.neutral100;
    }
  }

  // Main Build
  @override
  Widget build(BuildContext context) {
    final presensiAsync =
        ref.watch(presensiDetailStateProvider(widget.programId));
    final programNameAsync = ref.watch(programNameProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: presensiAsync.when(
        data: (presensi) => _buildContent(presensi, programNameAsync),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  // Content Builder
  Widget _buildContent(
      DetailPresensi presensi, AsyncValue<String> programNameAsync) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
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
    );
  }

  // App Bar
  Widget _buildAppBar() {
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

  // Program Info
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

  // Statistics Card
  Widget _buildStatisticsCard(DetailPresensi presensi) {
    final totalPertemuan = presensi.pertemuan.length;
    final hadir = presensi.pertemuan
        .where((p) => p.status.name.toUpperCase() == 'HADIR')
        .length;
    final persentase = totalPertemuan > 0
        ? (hadir / totalPertemuan * 100).toStringAsFixed(1)
        : '0.0';

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
              .where((p) => p.status.name.toUpperCase() == 'SAKIT')
              .length,
          AppColors.warning,
        ),
        _buildStatItem(
          'Izin',
          presensi.pertemuan
              .where((p) => p.status.name.toUpperCase() == 'IZIN')
              .length,
          Colors.blue,
        ),
        _buildStatItem(
          'Alpha',
          presensi.pertemuan
              .where((p) => p.status.name.toUpperCase() == 'ALPHA')
              .length,
          AppColors.error,
        ),
      ],
    );
  }

  // Stats Item
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

  // Pertemuan Grid
  Widget _buildPertemuanGrid(List<PresensiDetailItem> pertemuan) {
    if (pertemuan.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(
              Icons.event_busy,
              size: 48,
              color: AppColors.neutral400,
            ),
            verticalSpace(8),
            Text(
              'Belum ada data presensi',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: pertemuan.map((item) {
        // Konversi PresensiStatus ke string
        final statusString = item.status.name.toUpperCase();

        return _buildPertemuanItem(
          number: item.pertemuanKe,
          status: statusString, // Kirim sebagai string
          materi: item.materi,
          keterangan: item.keterangan,
        );
      }).toList(),
    );
  }

  Widget _buildPertemuanItem({
    required int number,
    required String status,
    String? materi,
    String? keterangan,
  }) {
    return InkWell(
      onTap: () => _showPertemuanDetail(
        number: number,
        status: status,
        materi: materi,
        keterangan: keterangan,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _getStatusBackgroundColor(status),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor(status),
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
      ),
    );
  }

  void _showPertemuanDetail({
    required int number,
    required String status,
    String? materi,
    String? keterangan,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detail Pertemuan $number',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', status),
            if (materi != null) _buildDetailRow('Materi', materi),
            if (keterangan != null) _buildDetailRow('Keterangan', keterangan),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Status Legend
  Widget _buildStatusLegend() {
    final statusList = [
      {'status': 'HADIR', 'label': 'Hadir'},
      {'status': 'SAKIT', 'label': 'Sakit'},
      {'status': 'IZIN', 'label': 'Izin'},
      {'status': 'ALPHA', 'label': 'Alpha'},
    ];

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
        ...statusList.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLegendItem(
                color: _getStatusBackgroundColor(item['status']!),
                borderColor: _getStatusColor(item['status']!),
                label: item['label']!,
              ),
            )),
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

  // Error State
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            FilledButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
