import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';

import '../../../../domain/entities/presensi/presensi_summary.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/presensi/manage_presensi_provider.dart';
import '../../../providers/presensi/presensi_detail_provider.dart';
import '../../../providers/program/program_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/sti_text_field_widget.dart';

class ManagePresensiConstants {
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int filterDebounceMs = 500;
}

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
  DateTime? _selectedMonth;
  String _sortBy = 'newest'; // 'newest', 'oldest', 'pertemuan'
  final List<DateTime> _monthList = [];
  bool isProcessing = false;
  Timer? _filterDebounce;
  final searchController = TextEditingController();
  String _searchQuery = '';

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

  bool _canManagePresensi(UserRole? userRole) {
    return userRole == UserRole.admin || userRole == UserRole.superAdmin;
  }

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = ManagePresensiConstants.maxRetries,
    int timeoutSeconds = ManagePresensiConstants.timeoutSeconds,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation().timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw TimeoutException('Operation timed out');
          },
        );
        return true; // Success case
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
                'Operation failed after $maxRetries attempts: ${e.toString()}');
          }
          return false; // Failure case after max retries
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false; // Fallback return
  }

  void _handleSearch(String query) {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(
        const Duration(milliseconds: ManagePresensiConstants.filterDebounceMs),
        () {
      setState(() {
        _searchQuery = query.trim();
        ref.refresh(managePresensiStateProvider(widget.programId));
      });
    });
  }

  // Generate list bulan untuk filter
  void _initializeMonthList() {
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      _monthList.add(
        DateTime(now.year, now.month - i, 1),
      );
    }
  }

// Method untuk filter by month
  List<PresensiPertemuan> _getFilteredList(List<PresensiPertemuan> list) {
    var filtered = list;

    // Filter by month
    if (_selectedMonth != null) {
      filtered = filtered
          .where((presensi) =>
              presensi.tanggal.year == _selectedMonth!.year &&
              presensi.tanggal.month == _selectedMonth!.month)
          .toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((presensi) =>
              presensi.materi
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false || presensi.pertemuanKe.toString().contains(_searchQuery))
          .toList();
    }

    return filtered;
  }

// Method untuk sorting
  List<PresensiPertemuan> _getSortedList(List<PresensiPertemuan> list) {
    switch (_sortBy) {
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

  double _calculateAverage(
    List<PresensiPertemuan> list,
    int Function(PresensiSummary) selector,
  ) {
    if (list.isEmpty) return 0;
    final total =
        list.fold<int>(0, (sum, item) => sum + selector(item.summary));
    return (total / list.length) * 100 / list.first.summary.totalSantri;
  }

  Future<bool> _confirmDelete(PresensiPertemuan presensi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Yakin ingin menghapus presensi pertemuan ke-${presensi.pertemuanKe}?'),
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

    if (confirmed == true) {
      await _executeDelete(presensi);
      return true;
    }
    return false;
  }

// Add delete execution method
  Future<void> _executeDelete(PresensiPertemuan presensi) async {
    setState(() => isProcessing = true);
    try {
      final success = await _handleOperationWithRetry(() async {
        await ref
            .read(managePresensiStateProvider(widget.programId).notifier)
            .deletePresensi(presensi.id);
      });

      if (success && mounted) {
        context.showSuccessSnackBar('Data presensi berhasil dihapus');
        ref.refresh(managePresensiStateProvider(widget.programId));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showActionDialog(BuildContext context, PresensiPertemuan presensi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Aksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Presensi'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(
                  'edit-presensi',
                  pathParameters: {
                    'programId': widget.programId,
                    'presensiId': presensi.id,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Hapus Presensi',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context); // Tutup dialog aksi
                _confirmDelete(presensi); // Tampilkan konfirmasi
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Lihat Detail'),
              onTap: () {
                Navigator.pop(context); // Tutup dialog aksi
                _showDetailDialog(context, presensi); // Tampilkan detail
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, PresensiPertemuan presensi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Presensi Pertemuan ${presensi.pertemuanKe}'),
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
                        '${santri.santriName}: ${santri.status.name.toUpperCase()}'
                        '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}'),
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

  String _getStatusText(PresensiPertemuan presensi) {
    if (presensi.daftarHadir.isEmpty) {
      return 'Belum Input';
    }
    return 'Sudah Input';
  }

  Widget _buildAppBar(BuildContext context) {
    final programName = ref.watch(programNameProvider(widget.programId));
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Presensi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            programName.when(
              data: (name) => Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              loading: () => const SizedBox(
                height: 14,
                width: 80,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgramInfo() {
    final programInfo = ref.watch(programProvider(widget.programId));

    return programInfo.when(
      data: (program) => Container(
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
            _buildInfoRow('Program', program.nama),
            const Divider(height: 16),
            _buildInfoRow('Kelas', program.kelas ?? 'Reguler'),
            const Divider(height: 16),
            _buildInfoRow(
                'Total Pertemuan', '${program.totalPertemuan} Pertemuan'),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            'Filter & Urutan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          STITextField(
            labelText: 'Cari Presensi',
            onChanged: _handleSearch,
            prefixIcon: const Icon(Icons.search),
            controller: searchController,
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Bulan',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _monthList.map((date) {
                    return DropdownMenuItem(
                      value: date,
                      child: Text(
                        DateFormat('MMMM yyyy').format(date),
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedMonth = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _sortBy,
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Terbaru'),
                    ),
                    const PopupMenuItem(
                      value: 'oldest',
                      child: Text('Terlama'),
                    ),
                    const PopupMenuItem(
                      value: 'pertemuan',
                      child: Text('Nomor Pertemuan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(List<PresensiPertemuan> presensiList) {
    // Filter list sesuai bulan yang dipilih jika ada
    final filteredList = _selectedMonth != null
        ? presensiList.where((p) {
            return p.tanggal.year == _selectedMonth!.year &&
                p.tanggal.month == _selectedMonth!.month;
          }).toList()
        : presensiList;

    // Hitung statistik
    final totalPertemuan = filteredList.length;
    final totalSantri =
        filteredList.isEmpty ? 0 : filteredList.first.summary.totalSantri;

    // Hitung rata-rata per status
    final avgHadir = _calculateAverage(filteredList, (s) => s.hadir);
    final avgSakit = _calculateAverage(filteredList, (s) => s.sakit);
    final avgIzin = _calculateAverage(filteredList, (s) => s.izin);
    final avgAlpha = _calculateAverage(filteredList, (s) => s.alpha);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistik Kehadiran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedMonth != null)
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth!),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.neutral600,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            // Overview stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Pertemuan',
                    totalPertemuan.toString(),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Total Santri',
                    totalSantri.toString(),
                    Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Attendance stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Rata-rata Hadir',
                    '${avgHadir.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Rata-rata Alpha',
                    '${avgAlpha.toStringAsFixed(1)}%',
                    Icons.cancel,
                    color: AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Rata-rata Izin',
                    '${avgIzin.toStringAsFixed(1)}%',
                    Icons.cancel,
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Rata-rata Sakit',
                    '${avgSakit.toStringAsFixed(1)}%',
                    Icons.cancel,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
              final _ = await ref.refresh(
                managePresensiStateProvider(widget.programId).future,
              );
            },
          ),
        ),
        horizontalSpace(16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.bar_chart,
            label: 'Lihat Statistik',
            color: AppColors.secondary,
            onTap: () {
              context.pushNamed(
                'presensi-statistics',
                pathParameters: {'programId': widget.programId},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPertemuanList(List<PresensiPertemuan> presensiList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pertemuan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        verticalSpace(16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: presensiList.length,
          itemBuilder: (context, index) {
            if (presensiList.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada data presensi',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.neutral600,
                  ),
                ),
              );
            }
            final presensi = presensiList[index];
            return _buildPertemuanCard(
              presensi: presensi,
              pertemuanKe: presensi.pertemuanKe,
              tanggal: presensi.tanggal,
              status: _getStatusText(presensi),
              onTap: () => _showActionDialog(context, presensi),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPertemuanCard({
    required int pertemuanKe,
    required DateTime tanggal,
    required String status,
    required VoidCallback onTap,
    required PresensiPertemuan presensi,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pertemuan number circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    pertemuanKe.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              horizontalSpace(16),
              // Pertemuan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertemuan $pertemuanKe',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      formatDate(tanggal),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      'Hadir: ${presensi.summary.hadir} | Sakit: ${presensi.summary.sakit} | '
                      'Izin: ${presensi.summary.izin} | Alpha: ${presensi.summary.alpha}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'Belum Input'
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: status == 'Belum Input'
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color color = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data presensi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context) {
    // Check user role access
    final userRole = ref.watch(userDataProvider).value?.role;
    if (!_canManagePresensi(userRole)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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

    final presensiAsync =
        ref.watch(managePresensiStateProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          presensiAsync.when(
            data: (presensiList) {
              final filteredList = _getFilteredList(presensiList);
              final sortedList = _getSortedList(filteredList);

              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildProgramInfo(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildFilterSection(),
                        ),
                        _buildStatisticsSection(sortedList),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildQuickActions(context),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: sortedList.isEmpty
                              ? _buildEmptyState()
                              : _buildPertemuanList(sortedList),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .refresh(managePresensiStateProvider(widget.programId)),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
