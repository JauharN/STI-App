import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../../../domain/entities/presensi/presensi_summary.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/manage_presensi_provider.dart';
import '../../../../providers/presensi/presensi_detail_provider.dart';
import '../../../../providers/presensi/presensi_statistics_provider.dart';
import '../../../../providers/program/program_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../utils/export_helper_util.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);
final sortByProvider = StateProvider<String>((ref) => 'newest');

class ManagePresensiPage extends ConsumerStatefulWidget {
  final String programId;

  const ManagePresensiPage({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<ManagePresensiPage> createState() => _ManagePresensiPageState();
}

class _ManagePresensiPageState extends ConsumerState<ManagePresensiPage> {
  // Constants for configuration
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int filterDebounceMs = 500;
  // static const int minSearchLength = 2;
  // static const int itemsPerPage = 10;
  // static const Duration retryDelay = Duration(seconds: 1);
  // static const maxMonthsHistory = 12;

  final List<DateTime> _monthList = [];
  bool isProcessing = false;
  Timer? _filterDebounce;

  // Controllers
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMonthList();
  }

  @override
  void dispose() {
    searchController.dispose();
    _filterDebounce?.cancel();
    super.dispose();
  }

  // RBAC Helper
  bool _canManagePresensi(String? userRole) {
    return userRole == RoleConstants.admin ||
        userRole == RoleConstants.superAdmin;
  }

  // Initialize month list for filtering
  void _initializeMonthList() {
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      _monthList.add(
        DateTime(now.year, now.month - i, 1),
      );
    }
  }

  // Error Handling with Retry Pattern
  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = maxRetries,
    int timeoutSeconds = timeoutSeconds,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation().timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () => throw TimeoutException('Operation timed out'),
        );
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
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  void _handleSearch(String query) {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(
      const Duration(milliseconds: filterDebounceMs),
      () {
        // Update search query di provider
        ref.read(searchQueryProvider.notifier).state = query.trim();
        _applyFilters();
      },
    );
  }

  void _applyFilters() {
    if (mounted) {
      setState(() {});
    }
  }

  List<PresensiPertemuan> _getFilteredList(List<PresensiPertemuan> list) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    var filtered = list;

    // Apply month filter
    if (selectedMonth != null) {
      filtered = filtered.where((presensi) {
        final isSameYear = presensi.tanggal.year == selectedMonth.year;
        final isSameMonth = presensi.tanggal.month == selectedMonth.month;
        return isSameYear && isSameMonth;
      }).toList();
    }

    // Apply search filter if query not empty
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((presensi) {
        final materiMatch = presensi.materi != null &&
            presensi.materi!.toLowerCase().contains(searchQuery.toLowerCase());

        final pertemuanMatch =
            presensi.pertemuanKe.toString().contains(searchQuery);

        final catatanMatch = presensi.catatan != null &&
            presensi.catatan!.toLowerCase().contains(searchQuery.toLowerCase());

        return materiMatch || pertemuanMatch || catatanMatch;
      }).toList();
    }

    return filtered;
  }

  // List Sorting Methods
  List<PresensiPertemuan> _getSortedList(List<PresensiPertemuan> list) {
    final sortBy = ref.watch(sortByProvider);

    switch (sortBy) {
      case 'newest':
        return list..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      case 'oldest':
        return list..sort((a, b) => a.tanggal.compareTo(b.tanggal));
      case 'pertemuan':
        return list..sort((a, b) => a.pertemuanKe.compareTo(b.pertemuanKe));
      default:
        return list;
    }
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    if (!_canManagePresensi(userRole)) {
      return _buildUnauthorizedView();
    }

    final presensiAsync =
        ref.watch(managePresensiStateProvider(widget.programId));
    final programNameAsync = ref.watch(programNameProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: presensiAsync.when(
        data: (presensiList) => CustomScrollView(
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
                      pengajarName: ref
                              .watch(programProvider(widget.programId))
                              .valueOrNull
                              ?.pengajarName ??
                          'Belum ditentukan',
                      kelas: ref
                              .watch(programProvider(widget.programId))
                              .valueOrNull
                              ?.kelas ??
                          'Reguler',
                    ),
                    verticalSpace(24),
                    _buildSearchBar(), // Tambahkan search bar
                    verticalSpace(16),
                    _buildStatisticsCard(presensiList),
                    verticalSpace(24),
                    _buildQuickActions(context),
                    verticalSpace(24),
                    _buildDateFilter(),
                    verticalSpace(16),
                    _buildPresensiList(presensiList),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  // Unauthorized View
  Widget _buildUnauthorizedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
            verticalSpace(16),
            Text(
              'Access Denied',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(8),
            Text(
              'You don\'t have permission to manage presensi',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // App Bar
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
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          onPressed: isProcessing ? null : _exportData,
        ),
      ],
    );
  }

  // Program Info Section
  Widget _buildProgramInfo({
    required String programName,
    String kelas = 'Reguler',
    String pengajarName = 'Belum ditentukan',
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
          _buildInfoRow('Pengajar', pengajarName),
        ],
      ),
    );
  }

  // Statistics Card
  Widget _buildStatisticsCard(List<PresensiPertemuan> presensiList) {
    if (presensiList.isEmpty) {
      return _buildEmptyStatistics();
    }

    final latestPresensi = presensiList.first;
    final summary = latestPresensi.summary;
    final persentaseKehadiran =
        (summary.hadir / summary.totalSantri * 100).toStringAsFixed(1);

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
                    '${summary.hadir} dari ${summary.totalSantri} Santri',
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
                  '$persentaseKehadiran%',
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
          _buildStatusBreakdown(latestPresensi.summary),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(PresensiSummary summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusItem(summary.hadir, 'Hadir', AppColors.success),
        _buildStatusItem(summary.sakit, 'Sakit', AppColors.warning),
        _buildStatusItem(summary.izin, 'Izin', Colors.blue),
        _buildStatusItem(summary.alpha, 'Alpha', AppColors.error),
      ],
    );
  }

  Widget _buildPresensiList(List<PresensiPertemuan> presensiList) {
    // Get current filters
    final filteredList = _getFilteredList(presensiList);
    final sortedList = _getSortedList(filteredList);

    if (sortedList.isEmpty) {
      // Check if searching
      final isSearching = ref.watch(searchQueryProvider).isNotEmpty;
      if (isSearching) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.neutral400,
              ),
              verticalSpace(16),
              Text(
                'Tidak ada hasil pencarian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        );
      }
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show search result info if searching
        if (ref.watch(searchQueryProvider).isNotEmpty) ...[
          Text(
            'Hasil Pencarian (${sortedList.length})',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
          ),
          verticalSpace(8),
        ],
        Text(
          'Daftar Kehadiran',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        verticalSpace(16),
        _buildPresensiGrid(sortedList),
      ],
    );
  }

  // Empty Statistics State
  Widget _buildEmptyStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.bar_chart,
              size: 48,
              color: AppColors.neutral400,
            ),
            verticalSpace(8),
            Text(
              'Belum ada data statistik',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Status Item widget
  Widget _buildStatusItem(int count, String label, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  // Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Input Presensi',
            color: AppColors.primary,
            onTap: () async {
              await context.pushNamed(
                'input-presensi',
                pathParameters: {'programId': widget.programId},
              );
              ref.refresh(managePresensiStateProvider(widget.programId));
            },
          ),
        ),
        horizontalSpace(16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.bar_chart,
            label: 'Lihat Statistik',
            color: AppColors.secondary,
            onTap: () => context.pushNamed(
              'presensi-statistics',
              pathParameters: {'programId': widget.programId},
            ),
          ),
        ),
      ],
    );
  }

  // Date Filter Section
  Widget _buildDateFilter() {
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                ..._monthList.map((date) => _buildFilterChip(
                      DateFormat('MMMM yyyy').format(date),
                      date,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final searchQuery = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Cari presensi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: _handleSearch,
      ),
    );
  }

  // Update method _buildFilterChip
  Widget _buildFilterChip(String label, DateTime? value) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isSelected = selectedMonth?.month == value?.month &&
        selectedMonth?.year == value?.year;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Update provider dan apply filter
          ref.read(selectedMonthProvider.notifier).state =
              selected ? value : null;
          _applyFilters();
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildPresensiGrid(List<PresensiPertemuan> presensiList) {
    if (presensiList.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: presensiList.length,
      itemBuilder: (context, index) => _buildPresensiCard(
        presensi: presensiList[index],
        onTap: () => _showActionDialog(context, presensiList[index]),
      ),
    );
  }

  Widget _buildPresensiCard({
    required PresensiPertemuan presensi,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      presensi.pertemuanKe.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM').format(presensi.tanggal),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              verticalSpace(12),
              if (presensi.materi != null) ...[
                Text(
                  'Materi:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  presensi.materi!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              _buildPresensiStats(presensi.summary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresensiStats(PresensiSummary summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          count: summary.hadir,
          label: 'Hadir',
          color: AppColors.success,
        ),
        _buildStatItem(
          count: summary.sakit,
          label: 'Sakit',
          color: AppColors.warning,
        ),
        _buildStatItem(
          count: summary.izin,
          label: 'Izin',
          color: Colors.blue,
        ),
        _buildStatItem(
          count: summary.alpha,
          label: 'Alpha',
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          verticalSpace(16),
          Text(
            'Belum ada data presensi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppColors.neutral600,
            ),
          ),
          verticalSpace(8),
          Text(
            'Silakan input data presensi terlebih dahulu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
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
            onPressed: () => ref.refresh(
              managePresensiStateProvider(widget.programId),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Action Dialog
  void _showActionDialog(BuildContext context, PresensiPertemuan presensi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Aksi Presensi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Presensi'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEdit(presensi);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Presensi',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(presensi);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Lihat Detail'),
              onTap: () {
                Navigator.pop(context);
                _showDetailDialog(context, presensi);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Detail Dialog
  void _showDetailDialog(BuildContext context, PresensiPertemuan presensi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detail Presensi Pertemuan ${presensi.pertemuanKe}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tanggal: ${formatDate(presensi.tanggal)}'),
              Text('Materi: ${presensi.materi ?? "-"}'),
              if (presensi.catatan?.isNotEmpty ?? false)
                Text('Catatan: ${presensi.catatan}'),
              const Divider(),
              const Text('Daftar Hadir:'),
              ...presensi.daftarHadir.map((santri) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${santri.santriName}: ${santri.status.label.toUpperCase()}'
                      '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}',
                    ),
                  )),
            ],
          ),
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

  // Delete Confirmation
  Future<void> _showDeleteConfirmation(PresensiPertemuan presensi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus presensi pertemuan ke-${presensi.pertemuanKe}?'
          '\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isProcessing = true);
      try {
        await _handleOperationWithRetry(() async {
          await ref
              .read(managePresensiStateProvider(widget.programId).notifier)
              .deletePresensi(presensi.id);
        });
        if (mounted) {
          context.showSuccessSnackBar('Presensi berhasil dihapus');
          ref.refresh(managePresensiStateProvider(widget.programId));
        }
      } finally {
        if (mounted) {
          setState(() => isProcessing = false);
        }
      }
    }
  }

  // Navigation Helper
  void _navigateToEdit(PresensiPertemuan presensi) {
    context.pushNamed(
      'edit-presensi',
      pathParameters: {
        'programId': widget.programId,
        'presensiId': presensi.id,
      },
    );
  }

  // Export Functionality
  Future<void> _exportData() async {
    setState(() => isProcessing = true);
    try {
      // Ambil data dari providers
      final selectedDate = ref.read(selectedMonthProvider);
      final stats =
          ref.read(presensiStatisticsProvider(widget.programId)).value;
      final programName =
          ref.read(programNameProvider(widget.programId)).value ??
              'Unknown Program';

      if (stats == null) {
        throw Exception('Data statistik tidak tersedia');
      }

      // Tentukan range tanggal
      DateTime? endDate;
      if (selectedDate != null) {
        endDate = selectedDate.add(const Duration(days: 31));
      }

      // Export to PDF
      final pdfFile = await ExportHelper.exportToPDF(
        title: 'Laporan Presensi $programName',
        stats: stats,
        startDate: selectedDate,
        endDate: endDate,
      );

      // Export to Excel
      final excelFile = await ExportHelper.exportToExcel(
        stats: stats,
        programName: programName,
        startDate: selectedDate,
        endDate: endDate,
      );

      if (!mounted) return;

      // Show format selection dialog
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
        setState(() => isProcessing = false);
      }
    }
  }

  // Helper Methods
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: color, size: 32),
            verticalSpace(8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
