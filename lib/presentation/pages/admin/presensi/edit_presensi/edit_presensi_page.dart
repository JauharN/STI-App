import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/presensi/detail_presensi.dart';
import '../../../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../../../domain/entities/presensi/presensi_status.dart';
import '../../../../../domain/entities/presensi/presensi_summary.dart';
import '../../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../../extensions/extensions.dart';
import '../../../../misc/constants.dart';
import '../../../../providers/presensi/presensi_detail_provider.dart';
import '../../../../providers/presensi/santri_list_provider.dart';
import '../../../../providers/program/program_detail_with_stats_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../widgets/presensi_widget/santri_presensi_card_widget.dart';

class EditPresensiPage extends ConsumerStatefulWidget {
  final String programId;
  final String pertemuanId;

  const EditPresensiPage({
    super.key,
    required this.programId,
    required this.pertemuanId,
  });

  @override
  ConsumerState<EditPresensiPage> createState() => _EditPresensiPageState();
}

class _EditPresensiPageState extends ConsumerState<EditPresensiPage> {
  // Form Controllers
  final formKey = GlobalKey<FormState>();
  final materiController = TextEditingController();
  final catatanController = TextEditingController();

  // State Variables
  bool isLoading = false;
  bool isSubmitting = false;
  DateTime selectedDate = DateTime.now();
  int pertemuanKe = 1;
  Map<String, PresensiStatus> santriStatus = {};
  Map<String, String> santriKeterangan = {};
  PresensiDetailItem? currentPertemuan;
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
      await _loadPertemuanData();
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadPertemuanData() async {
    await _handleOperationWithRetry(
      () async {
        final presensiDetail = await ref
            .read(presensiDetailStateProvider(widget.programId).future);

        final pertemuan = presensiDetail.pertemuan.firstWhere(
          (p) => '${widget.programId}_${p.pertemuanKe}' == widget.pertemuanId,
          orElse: () => throw Exception('Pertemuan tidak ditemukan'),
        );

        // Get santri list
        final santriList =
            ref.read(santriListProvider(widget.programId)).valueOrNull;
        if (santriList == null) throw Exception('Data santri tidak tersedia');

        setState(() {
          currentPertemuan = pertemuan;
          selectedDate = pertemuan.tanggal;
          pertemuanKe = pertemuan.pertemuanKe;
          materiController.text = pertemuan.materi ?? '';

          // Initialize status untuk setiap santri
          santriStatus = {for (var s in santriList) s.uid: pertemuan.status};

          // Initialize keterangan jika ada
          if (pertemuan.keterangan != null) {
            santriKeterangan = {
              for (var s in santriList) s.uid: pertemuan.keterangan!
            };
          }
        });
      },
      maxRetries: 3,
      delay: const Duration(seconds: 1),
    );
  }

  // Access Control
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!_canManagePresensi(userRole)) {
      context.showErrorSnackBar(
          'Anda tidak memiliki akses untuk mengelola presensi');
      Navigator.of(context).pop();
    }
  }

  bool _canManagePresensi(String? role) {
    return role == RoleConstants.admin || role == RoleConstants.superAdmin;
  }

  // Form Validation
  bool _validateForm() {
    if (!formKey.currentState!.validate()) return false;

    if (materiController.text.isEmpty) {
      context.showErrorSnackBar('Materi tidak boleh kosong');
      return false;
    }

    return true;
  }

  // Clean up
  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Edit Presensi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _showDeleteConfirmation,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (errorMessage != null) {
      return _buildErrorState();
    }

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgramInfo(),
            const SizedBox(height: 24),
            _buildPresensiForm(),
            const SizedBox(height: 24),
            _buildSantriList(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfo() {
    final program =
        ref.watch(programDetailWithStatsStateProvider(widget.programId));

    return program.when(
      data: (programData) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Program: ${programData.$1.name}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Pengajar: ${programData.$1.teacherName ?? "-"}'),
              const SizedBox(height: 8),
              Text('Pertemuan ke-$pertemuanKe'),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildPresensiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Picker
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
          child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
              ),
              child: Text('Tanggal: ${_formatDisplayDate(selectedDate)}')),
        ),
        const SizedBox(height: 16),

        // Pertemuan ke- (readonly)
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Pertemuan Ke',
            border: OutlineInputBorder(),
          ),
          child: Text('$pertemuanKe'),
        ),
        const SizedBox(height: 16),

        // Materi
        TextFormField(
          controller: materiController,
          decoration: const InputDecoration(
            labelText: 'Materi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Materi tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Catatan
        TextFormField(
          controller: catatanController,
          decoration: const InputDecoration(
            labelText: 'Catatan',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSantriList() {
    final santriListAsync = ref.watch(santriListProvider(widget.programId));

    return santriListAsync.when(
      data: (santriList) {
        if (santriList.isEmpty) {
          return const Center(
            child: Text('Tidak ada santri yang terdaftar'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with bulk actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Santri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<PresensiStatus>(
                  onSelected: (status) {
                    setState(() {
                      for (var santri in santriList) {
                        santriStatus[santri.uid] = status;
                      }
                    });
                  },
                  itemBuilder: (context) => PresensiStatus.values
                      .map(
                        (status) => PopupMenuItem(
                          value: status,
                          child: Text('Set Semua ${status.label}'),
                        ),
                      )
                      .toList(),
                  child: const Chip(
                    label: Text('Bulk Actions'),
                    avatar: Icon(Icons.edit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Santri list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: santriList.length,
              itemBuilder: (context, index) {
                final santri = santriList[index];
                return SantriPresensiCard(
                  santri: santri,
                  currentStatus:
                      santriStatus[santri.uid]?.name.toUpperCase() ?? 'HADIR',
                  keterangan: santriKeterangan[santri.uid] ?? '',
                  onStatusChanged: (status) {
                    setState(() {
                      santriStatus[santri.uid] = PresensiStatus.values
                          .firstWhere((e) => e.name.toUpperCase() == status);
                    });
                  },
                  onKeteranganChanged: (keterangan) {
                    setState(() {
                      santriKeterangan[santri.uid] = keterangan;
                    });
                  },
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () =>
                  ref.refresh(santriListProvider(widget.programId)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _showPreviewDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Terjadi kesalahan',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // Action Handlers
  void _showPreviewDialog() {
    if (!_validateForm()) return;

    final santriList =
        ref.read(santriListProvider(widget.programId)).valueOrNull;
    if (santriList == null) {
      context.showErrorSnackBar('Data santri tidak tersedia');
      return;
    }

    final daftarHadir = santriList.map((santri) {
      final status = santriStatus[santri.uid] ?? PresensiStatus.hadir;
      final keterangan = santriKeterangan[santri.uid];
      return SantriPresensi(
        santriId: santri.uid,
        santriName: santri.name,
        status: status,
        keterangan: keterangan,
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Preview Perubahan',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: ${_formatDisplayDate(selectedDate)}'),
              Text('Pertemuan ke-$pertemuanKe'),
              Text('Materi: ${materiController.text}'),
              if (catatanController.text.isNotEmpty)
                Text('Catatan: ${catatanController.text}'),
              const Divider(),
              const Text('Rekap Kehadiran:'),
              ...daftarHadir.map(
                (santri) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '${santri.santriName}: ${santri.status.name.toUpperCase()}'
                    '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleSubmit(daftarHadir);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(List<SantriPresensi> daftarHadir) async {
    setState(() => isSubmitting = true);
    try {
      final userRole = ref.read(userDataProvider).value?.role;
      if (!_canManagePresensi(userRole)) {
        throw Exception('Anda tidak memiliki akses untuk mengedit presensi');
      }

      final pertemuanToUpdate = PresensiPertemuan(
        id: widget.pertemuanId,
        programId: widget.programId,
        pertemuanKe: pertemuanKe,
        tanggal: selectedDate,
        materi: materiController.text,
        daftarHadir: daftarHadir,
        catatan:
            catatanController.text.isNotEmpty ? catatanController.text : null,
        createdAt: currentPertemuan?.tanggal ?? DateTime.now(),
        updatedAt: DateTime.now(),
        summary: PresensiSummary(
          totalSantri: daftarHadir.length,
          hadir:
              daftarHadir.where((s) => s.status == PresensiStatus.hadir).length,
          sakit:
              daftarHadir.where((s) => s.status == PresensiStatus.sakit).length,
          izin:
              daftarHadir.where((s) => s.status == PresensiStatus.izin).length,
          alpha:
              daftarHadir.where((s) => s.status == PresensiStatus.alpha).length,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await ref
          .read(presensiDetailStateProvider(widget.programId).notifier)
          .updatePresensi(pertemuanToUpdate);

      if (mounted) {
        context.showSuccessSnackBar('Berhasil update presensi');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal update presensi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Presensi'),
        content: Text(
          'Anda yakin ingin menghapus data presensi pertemuan ke-$pertemuanKe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => isSubmitting = true);
    try {
      final userRole = ref.read(userDataProvider).value?.role;
      if (!_canManagePresensi(userRole)) {
        throw Exception('Anda tidak memiliki akses untuk menghapus presensi');
      }

      await ref
          .read(presensiDetailStateProvider(widget.programId).notifier)
          .deletePresensi(widget.pertemuanId);

      if (mounted) {
        context.showSuccessSnackBar('Berhasil menghapus presensi');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal menghapus presensi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
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
        await Future.delayed(delay * retryCount);
      }
    }
    return false;
  }

  // Lifecycle Management
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset state when dependencies change
    _resetState();
  }

  @override
  void didUpdateWidget(EditPresensiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if programId or pertemuanId changes
    if (oldWidget.programId != widget.programId ||
        oldWidget.pertemuanId != widget.pertemuanId) {
      _initializeData();
    }
  }

  void _resetState() {
    setState(() {
      isLoading = false;
      isSubmitting = false;
      errorMessage = null;
    });
  }

  // Date & Time Formatting
  String _formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }
}
