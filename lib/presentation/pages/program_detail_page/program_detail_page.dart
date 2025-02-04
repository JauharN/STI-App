import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/presensi/detail_presensi.dart';
import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/presensi/presensi_summary.dart';
import '../../../domain/entities/presensi/program_detail.dart';

import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';

import '../../providers/presensi/presensi_detail_provider.dart';
import '../../providers/program/program_detail_with_stats_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/program_widget/pertemuan_list_widget.dart';
import '../../widgets/program_widget/program_action_widget.dart';
import '../../widgets/program_widget/program_header_widget.dart';
import '../../widgets/program_widget/program_stats_widget.dart';

class ProgramDetailPage extends ConsumerStatefulWidget {
  final String programId;

  const ProgramDetailPage({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends ConsumerState<ProgramDetailPage> {
  // Configuration Constants
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // State Variables
  bool isLoading = false;
  String? errorMessage;
  PresensiPertemuan? selectedPertemuan;

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
      await _loadProgramData();
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProgramData() async {
    await ref
        .read(programDetailWithStatsStateProvider(widget.programId).future);
    await ref.read(presensiDetailStateProvider(widget.programId).future);
  }

  // Access Control
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!ProgramDetail.canView(userRole ?? '')) {
      context.showErrorSnackBar('Anda tidak memiliki akses ke halaman ini');
      Navigator.pop(context);
    }
  }

  // RBAC Helpers
  bool _canManageProgram(String? role) {
    return role == RoleConstants.admin || role == RoleConstants.superAdmin;
  }

  bool _canInputPresensi(String? role) {
    return _canManageProgram(role);
  }

  bool _canAccessStatistics(String? role) {
    return role != null && RoleConstants.allRoles.contains(role);
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
      await _loadProgramData();
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  // Clean up
  @override
  void dispose() {
    // Add any cleanup if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch user role for RBAC
    final userRole = ref.watch(userDataProvider).value?.role;
    final isAdmin = _canManageProgram(userRole);

    // Watch program detail data
    final programDetailAsync = ref.watch(
      programDetailWithStatsStateProvider(widget.programId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: programDetailAsync.when(
        data: (data) => _buildMainContent(
          program: data.$1,
          summary: data.$2,
          isAdmin: isAdmin,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildMainContent({
    required ProgramDetail program,
    required PresensiSummary summary,
    required bool isAdmin,
  }) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(program.name),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildHeaderSection(program, isAdmin),
                const SizedBox(height: 24),
                _buildStatsSection(summary, isAdmin),
                const SizedBox(height: 24),
                if (isAdmin) ...[
                  _buildAdminActions(),
                  const SizedBox(height: 24),
                ],
                _buildPertemuanSection(isAdmin),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Program',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderSection(ProgramDetail program, bool isAdmin) {
    return ProgramHeaderWidget(
      program: program,
      isAdmin: isAdmin,
    );
  }

  Widget _buildStatsSection(PresensiSummary summary, bool isAdmin) {
    return ProgramStatsWidget(
      summary: summary,
      isAdmin: isAdmin,
    );
  }

  Widget _buildAdminActions() {
    return ProgramActionWidget(
      isAdmin: true,
      onInputPresensi: () => _navigateToInputPresensi(),
      onManagePresensi: () => _navigateToManagePresensi(),
      onViewStatistics: () => _navigateToStatistics(),
      onExportData: () => _handleExportData(),
    );
  }

  Widget _buildPertemuanSection(bool isAdmin) {
    final pertemuanAsync =
        ref.watch(presensiDetailStateProvider(widget.programId));

    return pertemuanAsync.when(
      data: (detailPresensi) => PertemuanListWidget(
        detailPresensi: detailPresensi,
        isAdmin: isAdmin,
        onPertemuanTap: _handlePertemuanTap,
        onAddPertemuan: isAdmin ? () => _handleAddPertemuan() : null,
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading pertemuan: ${error.toString()}',
          style: const TextStyle(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handlePertemuanTap(PresensiDetailItem pertemuan) {
    if (_canManageProgram(ref.read(userDataProvider).value?.role)) {
      _showPertemuanActionDialog(pertemuan);
    } else {
      _showPertemuanDetailDialog(pertemuan);
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

  // Navigation & Action Handlers
  void _navigateToInputPresensi() {
    if (!_canInputPresensi(ref.read(userDataProvider).value?.role)) {
      context
          .showErrorSnackBar('Anda tidak memiliki akses untuk input presensi');
      return;
    }

    context.pushNamed(
      'input-presensi',
      pathParameters: {'programId': widget.programId},
    );
  }

  void _navigateToManagePresensi() {
    if (!_canManageProgram(ref.read(userDataProvider).value?.role)) {
      context.showErrorSnackBar(
          'Anda tidak memiliki akses untuk mengelola presensi');
      return;
    }

    context.pushNamed(
      'manage-presensi',
      pathParameters: {'programId': widget.programId},
    );
  }

  void _navigateToStatistics() {
    if (!_canAccessStatistics(ref.read(userDataProvider).value?.role)) {
      context.showErrorSnackBar(
          'Anda tidak memiliki akses untuk melihat statistik');
      return;
    }

    context.pushNamed(
      'presensi-statistics',
      pathParameters: {'programId': widget.programId},
    );
  }

  Future<void> _handleAddPertemuan() async {
    if (!_canManageProgram(ref.read(userDataProvider).value?.role)) {
      context.showErrorSnackBar(
          'Anda tidak memiliki akses untuk menambah pertemuan');
      return;
    }

    setState(() => isLoading = true);
    try {
      final programDetailResult = await ref.read(
        programDetailWithStatsStateProvider(widget.programId).future,
      );

      if (programDetailResult.$1.totalMeetings == 0) {
        if (mounted) {
          context.showErrorSnackBar('Total pertemuan belum diatur');
        }
        return;
      }

      final currentPertemuan =
          ref.read(presensiDetailStateProvider(widget.programId));
      final nextPertemuanKe = currentPertemuan.valueOrNull?.length ?? 0 + 1;

      if (nextPertemuanKe > programDetailResult.$1.totalMeetings) {
        if (mounted) {
          context.showErrorSnackBar(
            'Sudah mencapai batas maksimal pertemuan (${programDetailResult.$1.totalMeetings})',
          );
        }
        return;
      }

      if (mounted) {
        context.pushNamed(
          'input-presensi',
          pathParameters: {
            'programId': widget.programId,
            'pertemuanKe': nextPertemuanKe.toString(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal menambah pertemuan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleExportData() async {
    if (!_canManageProgram(ref.read(userDataProvider).value?.role)) {
      context
          .showErrorSnackBar('Anda tidak memiliki akses untuk mengekspor data');
      return;
    }

    setState(() => isLoading = true);
    try {
      final programDetailResult = await ref.read(
        programDetailWithStatsStateProvider(widget.programId).future,
      );

      final pertemuan = ref.read(presensiDetailStateProvider(widget.programId));

      if (pertemuan.valueOrNull?.isEmpty ?? true) {
        if (mounted) {
          context.showErrorSnackBar('Tidak ada data presensi untuk diekspor');
        }
        return;
      }

      if (mounted) {
        // Navigate to export page with data
        context.pushNamed(
          'export-presensi',
          pathParameters: {
            'programId': widget.programId,
            'programName': programDetailResult.$1.name,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal mengekspor data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showPertemuanActionDialog(PresensiDetailItem pertemuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pertemuan ke-${pertemuan.pertemuanKe}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Presensi'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToEditPresensi(pertemuan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Hapus Presensi'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(pertemuan);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPertemuanDetailDialog(PresensiDetailItem pertemuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pertemuan ke-${pertemuan.pertemuanKe}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${formatDate(pertemuan.tanggal)}',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (pertemuan.materi?.isNotEmpty ?? false) ...[
              Text(
                'Materi:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                pertemuan.materi!,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditPresensi(PresensiDetailItem pertemuan) {
    context.pushNamed(
      'input-presensi',
      pathParameters: {
        'programId': widget.programId,
        'pertemuanId': '${widget.programId}_${pertemuan.pertemuanKe}',
      },
    );
  }

  Future<void> _showDeleteConfirmation(PresensiDetailItem pertemuan) async {
    final confirm = await context.showConfirmDialog(
      title: 'Hapus Presensi',
      message:
          'Anda yakin ingin menghapus data presensi pertemuan ke-${pertemuan.pertemuanKe}?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (confirm != true || !mounted) return;

    setState(() => isLoading = true);
    try {
      await ref
          .read(presensiDetailStateProvider(widget.programId).notifier)
          .deletePresensi('${widget.programId}_${pertemuan.pertemuanKe}');

      if (mounted) {
        context.showSuccessSnackBar('Berhasil menghapus data presensi');
        await _refreshData();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
            'Gagal menghapus data presensi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // State Management Helpers
  void _resetState() {
    setState(() {
      isLoading = false;
      errorMessage = null;
      selectedPertemuan = null;
    });
  }

  // Lifecycle Helpers
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetState();
  }

  @override
  void didUpdateWidget(ProgramDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programId != widget.programId) {
      _initializeData();
    }
  }
}
