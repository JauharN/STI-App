import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/presensi/presensi_statistics_data.dart';
import '../../../domain/entities/presensi/santri_statistics.dart';
import '../../../domain/entities/presensi/presensi_status.dart';
import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/presensi/presensi_detail_provider.dart';
import '../../providers/presensi/presensi_statistics_provider.dart';
import '../../providers/program/program_detail_with_stats_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../utils/export_helper_util.dart';

class PresensiStatisticsPage extends ConsumerStatefulWidget {
  final String programId;

  const PresensiStatisticsPage({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<PresensiStatisticsPage> createState() =>
      _PresensiStatisticsPageState();
}

class _PresensiStatisticsPageState
    extends ConsumerState<PresensiStatisticsPage> {
  // Configuration Constants
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // State Variables
  bool isLoading = false;
  bool isExporting = false;
  DateTime? startDate;
  DateTime? endDate;
  String filterBy = 'month'; // 'all', 'month', 'semester', 'custom'
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _checkAccess();
    });
  }

  // Initialization
  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    try {
      _initializeFilters();
      await _loadStatisticsData();
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _initializeFilters() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _loadStatisticsData() async {
    try {
      await ref.read(
        presensiStatisticsProvider(widget.programId).future,
      );
      await ref.read(
        programDetailWithStatsStateProvider(widget.programId).future,
      );
    } catch (e) {
      throw Exception('Gagal memuat data statistik: ${e.toString()}');
    }
  }

  // Access Control
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!_canAccessStatistics(userRole)) {
      context.showErrorSnackBar('Anda tidak memiliki akses ke halaman ini');
      Navigator.pop(context);
    }
  }

  // RBAC Helpers
  bool _canAccessStatistics(String? role) {
    if (role == null) return false;
    return role == RoleConstants.superAdmin ||
        role == RoleConstants.admin ||
        role == RoleConstants.santri;
  }

  bool _canExportData(String? role) {
    if (role == null) return false;
    return role == RoleConstants.superAdmin || role == RoleConstants.admin;
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
              'Operasi gagal setelah $maxRetries percobaan: ${e.toString()}',
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
      if (mounted) {
        setState(() => isLoading = true);
      }
      await _loadStatisticsData();
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  // Date Filter Helpers
  String _formatDateRange() {
    if (startDate == null || endDate == null) return 'Pilih Rentang Tanggal';
    return '${formatDate(startDate!)} - ${formatDate(endDate!)}';
  }

  void _setFilterPeriod(String period) {
    final now = DateTime.now();
    setState(() {
      filterBy = period;
      switch (period) {
        case 'all':
          startDate = null;
          endDate = null;
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'semester':
          if (now.month <= 6) {
            startDate = DateTime(now.year, 1, 1);
            endDate = DateTime(now.year, 6, 30);
          } else {
            startDate = DateTime(now.year, 7, 1);
            endDate = DateTime(now.year, 12, 31);
          }
          break;
      }
    });
    _applyDateFilter();
  }

  Future<void> _applyDateFilter() async {
    if (startDate == null || endDate == null) return;

    setState(() => isLoading = true);
    try {
      await ref
          .read(presensiStatisticsProvider(widget.programId).notifier)
          .refreshWithDateRange(startDate!, endDate!);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Widget Build Methods
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(presensiStatisticsProvider(widget.programId));
    final programNameAsync = ref.watch(programNameProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, programNameAsync),
      body: statsAsync.when(
        data: (stats) => _buildContent(stats),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<String> programNameAsync,
  ) {
    final userRole = ref.watch(userDataProvider).value?.role;

    return AppBar(
      title: Column(
        children: [
          const Text('Statistik Presensi'),
          programNameAsync.when(
            data: (name) => Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            loading: () => const SizedBox(height: 14),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (_canExportData(userRole))
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: isExporting ? null : _exportData,
          ),
      ],
    );
  }

  Widget _buildContent(PresensiStatisticsData stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          const SizedBox(height: 24),
          _buildOverviewSection(stats),
          const SizedBox(height: 24),
          _buildTrendSection(stats),
          const SizedBox(height: 24),
          _buildStatusBreakdownSection(stats),
          const SizedBox(height: 24),
          _buildSantriStatisticsSection(stats),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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
            'Filter Periode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterChips(),
          if (filterBy == 'custom') ...[
            const SizedBox(height: 16),
            _buildDateRangeDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip('Semua', 'all'),
        _buildFilterChip('Bulan Ini', 'month'),
        _buildFilterChip('Semester', 'semester'),
        _buildFilterChip('Kustom', 'custom'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      selected: filterBy == value,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          if (value == 'custom') {
            _selectDateRange();
          } else {
            _setFilterPeriod(value);
          }
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDateRangeDisplay() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(_formatDateRange()),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now(),
        end: endDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        filterBy = 'custom';
      });
      _applyDateFilter();
    }
  }

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
            const SizedBox(height: 16),
            Text(
              'Error: ${error.toString()}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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

  Widget _buildOverviewSection(PresensiStatisticsData stats) {
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
            'Ringkasan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Total Pertemuan',
                  stats.totalPertemuan.toString(),
                  Icons.calendar_month,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewCard(
                  'Total Santri',
                  stats.totalSantri.toString(),
                  Icons.people,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(PresensiStatisticsData stats) {
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
            'Trend Kehadiran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(_buildLineChartData(stats.trendKehadiran)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdownSection(PresensiStatisticsData stats) {
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
            'Breakdown Status Kehadiran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusGrid(stats),
        ],
      ),
    );
  }

  Widget _buildSantriStatisticsSection(PresensiStatisticsData stats) {
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
                'Statistik per Santri',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_canExportData(ref.read(userDataProvider).value?.role))
                TextButton.icon(
                  icon: const Icon(Icons.download, size: 20),
                  label: const Text('Export'),
                  onPressed: () => _exportSantriStatistics(stats.santriStats),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSantriList(stats.santriStats),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(Map<String, double> trendData) {
    if (trendData.isEmpty) {
      return LineChartData();
    }

    final spots = trendData.entries.map((e) {
      final date = DateTime.parse(e.key);
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        e.value,
      );
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid(PresensiStatisticsData stats) {
    final totalHadir = stats.totalByStatus[PresensiStatus.hadir] ?? 0;
    final totalSakit = stats.totalByStatus[PresensiStatus.sakit] ?? 0;
    final totalIzin = stats.totalByStatus[PresensiStatus.izin] ?? 0;
    final totalAlpha = stats.totalByStatus[PresensiStatus.alpha] ?? 0;
    final total = totalHadir + totalSakit + totalIzin + totalAlpha;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          'Hadir',
          totalHadir,
          total,
          AppColors.success,
          Icons.check_circle_outline,
        ),
        _buildStatusCard(
          'Sakit',
          totalSakit,
          total,
          AppColors.warning,
          Icons.sick_outlined,
        ),
        _buildStatusCard(
          'Izin',
          totalIzin,
          total,
          Colors.blue,
          Icons.event_busy_outlined,
        ),
        _buildStatusCard(
          'Alpha',
          totalAlpha,
          total,
          AppColors.error,
          Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

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
            '$count dari $total',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriList(List<SantriStatistics> santriStats) {
    // Sort santri by attendance percentage (descending)
    final sortedStats = [...santriStats]
      ..sort((a, b) => b.persentaseKehadiran.compareTo(a.persentaseKehadiran));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedStats.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) => _buildSantriStatisticsItem(
        sortedStats[index],
        index + 1,
      ),
    );
  }

  Widget _buildSantriStatisticsItem(SantriStatistics stats, int rank) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        stats.santriName,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Hadir: ${stats.statusCount[PresensiStatus.hadir] ?? 0} dari ${stats.totalPertemuan}',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AppColors.neutral600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              _getPercentageColor(stats.persentaseKehadiran).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${stats.persentaseKehadiran.toStringAsFixed(1)}%',
          style: GoogleFonts.plusJakartaSans(
            color: _getPercentageColor(stats.persentaseKehadiran),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _exportData() async {
    setState(() => isExporting = true);

    try {
      final stats =
          ref.read(presensiStatisticsProvider(widget.programId)).value;
      final programName =
          ref.read(programNameProvider(widget.programId)).value ??
              'Unknown Program';

      if (stats == null) {
        throw Exception('Data statistik tidak tersedia');
      }

      // Export ke PDF
      final pdfFile = await ExportHelper.exportToPDF(
        title: 'Laporan Presensi $programName',
        stats: stats,
        startDate: startDate,
        endDate: endDate,
      );

      // Export ke Excel
      final excelFile = await ExportHelper.exportToExcel(
        stats: stats,
        programName: programName,
        startDate: startDate,
        endDate: endDate,
      );

      // Show dialog untuk pilih format
      if (!mounted) return;
      final format = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Format Export'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF'),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Excel'),
                onTap: () => Navigator.pop(context, 'excel'),
              ),
            ],
          ),
        ),
      );

      if (format == null) return;

      final fileToShare = format == 'pdf' ? pdfFile : excelFile;
      await ExportHelper.shareFile(fileToShare);

      if (mounted) {
        context.showSuccessSnackBar('Data berhasil diexport');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal mengexport data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> _exportSantriStatistics(List<SantriStatistics> stats) async {
    setState(() => isExporting = true);

    try {
      final programName =
          ref.read(programNameProvider(widget.programId)).value ??
              'Unknown Program';

      // Create PresensiStatisticsData with only santri stats
      final statsData = PresensiStatisticsData(
        programId: widget.programId,
        totalPertemuan: stats.firstOrNull?.totalPertemuan ?? 0,
        totalSantri: stats.length,
        trendKehadiran: {},
        totalByStatus: {},
        santriStats: stats,
      );

      final pdfFile = await ExportHelper.exportToPDF(
        title: 'Statistik Santri $programName',
        stats: statsData,
        startDate: startDate,
        endDate: endDate,
      );

      await ExportHelper.shareFile(pdfFile);

      if (mounted) {
        context.showSuccessSnackBar('Statistik santri berhasil diexport');
      }
    } catch (e) {
      if (mounted) {
        context
            .showErrorSnackBar('Gagal mengexport statistik: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  // State Management Helpers
  void _resetState() {
    setState(() {
      isLoading = false;
      isExporting = false;
      errorMessage = null;
    });
  }

  // Lifecycle Helpers
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetState();
  }

  @override
  void didUpdateWidget(PresensiStatisticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programId != widget.programId) {
      _initializeData();
    }
  }

  @override
  void dispose() {
    // Add any cleanup if needed
    super.dispose();
  }
}
