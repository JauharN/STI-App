import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';

import '../../../providers/presensi/manage_presensi_provider.dart';
import '../../../providers/presensi/presensi_detail_provider.dart';
import '../../../providers/presensi/presensi_statistics_provider.dart';
import '../../../providers/program/program_provider.dart';

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

  // Import month picker
  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      // Hanya tampilkan view bulan
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  // Method untuk filter by month
  List<PresensiPertemuan> _getFilteredList(List<PresensiPertemuan> list) {
    if (_selectedMonth == null) return list;

    return list
        .where((presensi) =>
            presensi.tanggal.year == _selectedMonth!.year &&
            presensi.tanggal.month == _selectedMonth!.month)
        .toList();
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

  @override
  Widget build(BuildContext context) {
    final presensiAsync =
        ref.watch(managePresensiStateProvider(widget.programId));
    final programNameAsync = ref.watch(programNameProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: presensiAsync.when(
        data: (presensiList) {
          final filteredList = _getFilteredList(presensiList);
          final sortedList = _getSortedList(filteredList);

          CustomScrollView(
            slivers: [
              // Custom App Bar
              _buildAppBar(context),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Program Info Section
                      _buildProgramInfo(),

                      verticalSpace(24),

                      // Quick Actions Section
                      _buildQuickActions(context),

                      verticalSpace(24),

                      if (sortedList.isEmpty)
                        _buildEmptyState()
                      else
                        _buildPertemuanList(sortedList),
                      _buildPertemuanList(presensiList),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${error.toString()}'),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(managePresensiStateProvider(widget.programId)),
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
          'Kelola Presensi',
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
              await ref.refresh(
                  managePresensiStateProvider(widget.programId).future);
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

  String _getStatusText(PresensiPertemuan presensi) {
    if (presensi.daftarHadir.isEmpty) {
      return 'Belum Input';
    }
    return 'Sudah Input';
  }

// Dialog konfirmasi aksi
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
                  Navigator.pop(context);
                  _showDetailDialog(context, presensi);
                }),
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

  Future<void> _confirmDelete(
      BuildContext context, PresensiPertemuan presensi) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Yakin ingin menghapus data pertemuan ke-${presensi.pertemuanKe}?'),
            const SizedBox(height: 8),
            const Text(
              'Data yang sudah dihapus tidak dapat dikembalikan.',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              _executeDelete(presensi);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Add delete execution method
  Future<void> _executeDelete(PresensiPertemuan presensi) async {
    try {
      await ref
          .read(managePresensiStateProvider(widget.programId).notifier)
          .deletePresensi(presensi.id);

      if (mounted) {
        context.showSuccessSnackBar('Data presensi berhasil dihapus');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectMonth,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _selectedMonth == null
                          ? 'Semua Bulan'
                          : DateFormat('MMMM yyyy').format(_selectedMonth!),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.neutral800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Terbaru')),
              const PopupMenuItem(value: 'oldest', child: Text('Terlama')),
              const PopupMenuItem(
                  value: 'pertemuan', child: Text('Nomor Pertemuan')),
            ],
          ),
        ],
      ),
    );
  }
}
