import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/presensi/presensi_status.dart';
import '../../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../../../domain/entities/program.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/input_presensi_provider.dart';
import '../../../../providers/program/program_provider.dart';
import '../../../../providers/user/enrolled_santri_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../extensions/extensions.dart';
import '../../../../widgets/presensi_widget/bulk_action_bottom_sheet_widget.dart';
import '../../../../widgets/presensi_widget/santri_presensi_card_widget.dart';

// Constants
const int _maxRetries = 3;
const int _timeoutSeconds = 30;
const int _maxPertemuan = 8;
const Duration _retryDelay = Duration(seconds: 1);

// State Providers
final presensiStatusProvider =
    StateProvider.family<String, String>((ref, santriId) => 'HADIR');
final presensiKeteranganProvider =
    StateProvider.family<String, String>((ref, santriId) => '');
final selectedSantriProvider = StateProvider<Set<String>>((ref) => {});

class InputPresensiPage extends ConsumerStatefulWidget {
  final String programId;

  const InputPresensiPage({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<InputPresensiPage> createState() => _InputPresensiPageState();
}

class _InputPresensiPageState extends ConsumerState<InputPresensiPage> {
  // Controllers
  final materiController = TextEditingController();
  final catatanController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // State variables
  DateTime selectedDate = DateTime.now();
  int pertemuanKe = 1;
  bool isSubmitting = false;
  String? errorMessage;
  Set<String> selectedSantriIds = {};

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _validateProgramData();
  }

  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  // RBAC Helper
  bool _canInputPresensi(String? role) =>
      role == RoleConstants.admin || role == RoleConstants.superAdmin;

  // Access Control
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!_canInputPresensi(userRole)) {
      if (context.mounted) {
        context.showErrorSnackBar(
            'Anda tidak memiliki akses untuk input presensi');
        context.pop();
      }
    }
  }

  // Program Data Validation
  Future<void> _validateProgramData() async {
    try {
      final program = await ref.read(programProvider(widget.programId).future);

      if (program.pengajarIds.isEmpty) {
        throw Exception('Program belum memiliki pengajar');
      }

      if (program.enrolledSantriIds.isEmpty) {
        throw Exception('Program belum memiliki santri terdaftar');
      }

      setState(() {
        pertemuanKe =
            (program.totalPertemuan != null && program.totalPertemuan! > 0)
                ? 1 // Start from pertemuan 1
                : 1;
      });
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }
  }

  // Validation Methods
  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now.add(const Duration(days: 1))) &&
        date.isAfter(now.subtract(const Duration(days: 30)));
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) return false;

    if (materiController.text.trim().isEmpty) {
      context.showErrorSnackBar('Materi tidak boleh kosong');
      return false;
    }

    if (!_isValidDate(selectedDate)) {
      context.showErrorSnackBar('Tanggal tidak valid');
      return false;
    }

    // Validate program data
    final program = ref.read(programProvider(widget.programId)).valueOrNull;
    if (program == null || program.enrolledSantriIds.isEmpty) {
      context
          .showErrorSnackBar('Program tidak valid atau belum memiliki santri');
      return false;
    }

    return true;
  }

  // Error Handling
  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation,
  ) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await operation().timeout(
          const Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException('Operation timed out'),
        );
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
              'Operasi gagal setelah $_maxRetries percobaan: ${e.toString()}',
            );
          }
          return false;
        }
        await Future.delayed(_retryDelay * retryCount);
      }
    }
    return false;
  }

  // Data Preparation
  Future<List<SantriPresensi>> _prepareDaftarHadir() async {
    final program = await ref.read(programProvider(widget.programId).future);
    List<SantriPresensi> daftarHadir = [];

    for (var santriId in program.enrolledSantriIds) {
      // Get user data
      final user = await ref.read(userDataProvider.future);
      if (user == null) continue;

      final status = ref.read(presensiStatusProvider(santriId));
      final keterangan = ref.read(presensiKeteranganProvider(santriId));

      final presensiStatus = PresensiStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == status,
        orElse: () => PresensiStatus.hadir,
      );

      daftarHadir.add(
        SantriPresensi(
          santriId: santriId,
          santriName: user.name,
          status: presensiStatus,
          keterangan: keterangan,
        ),
      );
    }

    return daftarHadir;
  }

  // Action Methods
  Future<void> _confirmSubmit() async {
    if (!_validateForm()) return;

    final daftarHadir = await _prepareDaftarHadir();
    if (daftarHadir.isEmpty) {
      context.showErrorSnackBar('Tidak ada data santri untuk disubmit');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Submit',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
              ),
              const SizedBox(height: 4),
              Text('Pertemuan ke-$pertemuanKe'),
              const SizedBox(height: 4),
              Text('Materi: ${materiController.text}'),
              if (catatanController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Catatan: ${catatanController.text}'),
              ],
              const Divider(height: 16),
              Text(
                'Daftar Hadir:',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...daftarHadir.map((santri) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(
                      '${santri.santriName}: ${santri.status.label}'
                      '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}',
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _submitPresensi(daftarHadir);
    }
  }

  Future<void> _submitPresensi(List<SantriPresensi> daftarHadir) async {
    setState(() => isSubmitting = true);

    try {
      await ref.read(inputPresensiControllerProvider.notifier).submitPresensi(
            programId: widget.programId,
            pertemuanKe: pertemuanKe,
            tanggal: selectedDate,
            materi: materiController.text.trim(),
            daftarHadir: daftarHadir,
            catatan: catatanController.text.trim(),
          );

      if (mounted) {
        context.showSuccessSnackBar('Presensi berhasil disimpan');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal menyimpan presensi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _updateSantriPresensi(
    String santriId,
    String status, {
    String keterangan = '',
  }) {
    ref.read(presensiStatusProvider(santriId).notifier).state = status;
    if (keterangan.isNotEmpty) {
      ref.read(presensiKeteranganProvider(santriId).notifier).state =
          keterangan;
    }
  }

  void _toggleSantriSelection(String santriId) {
    setState(() {
      if (selectedSantriIds.contains(santriId)) {
        selectedSantriIds.remove(santriId);
      } else {
        selectedSantriIds.add(santriId);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.neutral900,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null && _isValidDate(date)) {
      setState(() => selectedDate = date);
    }
  }

  void _showBulkAction() {
    if (selectedSantriIds.isEmpty) {
      context.showErrorSnackBar('Pilih santri terlebih dahulu');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => BulkActionBottomSheet(
        programId: widget.programId,
        santriIds: selectedSantriIds.toList(),
        pertemuanKe: pertemuanKe,
        onStatusUpdate: (status, keterangan) {
          for (var santriId in selectedSantriIds) {
            _updateSantriPresensi(santriId, status, keterangan: keterangan);
          }
          context.pop();
        },
      ),
    );
  }

  // UI Components
  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider(widget.programId));

    if (errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: program.when(
        data: (programData) => Stack(
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgramInfo(programData),
                    verticalSpace(24),
                    _buildPresensiForm(),
                    verticalSpace(24),
                    _buildSantriSection(programData.enrolledSantriIds),
                    verticalSpace(32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
            if (isSubmitting) _buildLoadingOverlay(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: GoogleFonts.plusJakartaSans(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Input Presensi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              verticalSpace(16),
              Text(
                errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(24),
              FilledButton.icon(
                onPressed: () => ref.refresh(programProvider(widget.programId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Form Components
  Widget _buildProgramInfo(Program program) {
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
            'Program: ${program.nama}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengajar: ${program.pengajarNames.isNotEmpty ? program.pengajarNames.join(", ") : "-"}',
          ),
          const SizedBox(height: 8),
          Text('Pertemuan ke-$pertemuanKe'),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMMM yyyy').format(selectedDate),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral900,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPertemuanCounter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pertemuan ke:',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral900,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: pertemuanKe > 1
                    ? () => setState(() => pertemuanKe--)
                    : null,
                color:
                    pertemuanKe > 1 ? AppColors.primary : AppColors.neutral300,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$pertemuanKe',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: pertemuanKe < _maxPertemuan
                    ? () => setState(() => pertemuanKe++)
                    : null,
                color: pertemuanKe < _maxPertemuan
                    ? AppColors.primary
                    : AppColors.neutral300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMateriInput() {
    return TextFormField(
      controller: materiController,
      decoration: InputDecoration(
        labelText: 'Materi',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Materi tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildCatatanInput() {
    return TextFormField(
      controller: catatanController,
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
      decoration: InputDecoration(
        labelText: 'Catatan (Opsional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignLabelWithHint: true,
      ),
      maxLines: 2,
    );
  }

  Widget _buildPresensiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePicker(),
        verticalSpace(16),
        _buildPertemuanCounter(),
        verticalSpace(16),
        _buildMateriInput(),
        verticalSpace(16),
        _buildCatatanInput(),
      ],
    );
  }

  Widget _buildSantriSection(List<String> enrolledSantriIds) {
    if (enrolledSantriIds.isEmpty) {
      return _buildEmptyState(
        'Belum ada santri terdaftar di program ini',
        'Silakan tambahkan santri terlebih dahulu',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Text(
              '${selectedSantriIds.length} terpilih',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        verticalSpace(16),
        Consumer(
          builder: (context, ref, _) {
            final santriListAsync =
                ref.watch(enrolledSantriProvider(widget.programId));

            return santriListAsync.when(
              data: (santriList) {
                if (santriList.isEmpty) {
                  return _buildEmptyState(
                    'Belum ada santri terdaftar',
                    'Silakan tambahkan santri ke program ini',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: santriList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final santri = santriList[index];
                    final isSelected = selectedSantriIds.contains(santri.uid);
                    final status =
                        ref.watch(presensiStatusProvider(santri.uid));
                    final keterangan =
                        ref.watch(presensiKeteranganProvider(santri.uid));

                    return Column(
                      children: [
                        CheckboxListTile(
                          value: isSelected,
                          onChanged: (checked) =>
                              _toggleSantriSelection(santri.uid),
                          title: Text(
                            santri.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: SantriPresensiCard(
                            santri: santri,
                            currentStatus: status,
                            keterangan: keterangan,
                            onStatusChanged: (newStatus) =>
                                _updateSantriPresensi(santri.uid, newStatus),
                            onKeteranganChanged: (newKeterangan) =>
                                _updateSantriPresensi(
                              santri.uid,
                              status,
                              keterangan: newKeterangan,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: isSubmitting ? null : _confirmSubmit,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
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
          : const Text('Submit Presensi'),
    );
  }

  Widget _buildFloatingActionButton() {
    if (selectedSantriIds.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: _showBulkAction,
      backgroundColor: AppColors.primary,
      label: Text('Update ${selectedSantriIds.length} Santri'),
      icon: const Icon(Icons.group_add),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.neutral400,
          ),
          verticalSpace(16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
