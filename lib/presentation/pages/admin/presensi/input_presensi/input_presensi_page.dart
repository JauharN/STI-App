import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../../domain/entities/presensi/presensi_status.dart';
import '../../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/input_presensi_provider.dart';
import '../../../../providers/presensi/santri_list_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../widgets/presensi_widget/bulk_action_bottom_sheet_widget.dart';
import '../../../../widgets/presensi_widget/santri_presensi_card_widget.dart';

// Constants untuk reusability dan maintainability
const int _maxRetries = 3;
const int _timeoutSeconds = 30;
const int _maxPertemuan = 8;
const Duration _retryDelay = Duration(seconds: 1);

// State Providers untuk manajemen status presensi
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

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _initializeDefaults();
  }

  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  // Access Control - Menggunakan string roles sesuai perbaikan auth
  void _checkAccess() {
    final userRole = ref.read(userDataProvider).value?.role;
    if (!_canInputPresensi(userRole)) {
      if (context.mounted) {
        context.pop();
        context.showErrorSnackBar(
            'Anda tidak memiliki akses untuk input presensi');
      }
    }
  }

  bool _canInputPresensi(String? role) =>
      role == 'admin' || role == 'superAdmin';

  // Initialization
  void _initializeDefaults() {
    final santriList = ref.read(santriListProvider(widget.programId));
    santriList.whenData((list) {
      for (var santri in list) {
        ref.read(presensiStatusProvider(santri.uid).notifier).state = 'HADIR';
        ref.read(presensiKeteranganProvider(santri.uid).notifier).state = '';
      }
    });
  }

  // Validation
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

    return true;
  }

  // Error Handling dengan Retry Mechanism
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
              'Operation failed after $_maxRetries attempts: ${e.toString()}',
            );
          }
          return false;
        }
        await Future.delayed(_retryDelay * retryCount);
      }
    }
    return false;
  }

  // Action Methods
  Future<void> _confirmSubmit(List<SantriPresensi> daftarHadir) async {
    if (!_validateForm()) return;

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
                  'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}'),
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
                      '${santri.santriName}: ${santri.status}'
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
      final success = await _handleOperationWithRetry(
        () => ref.read(inputPresensiControllerProvider.notifier).submitPresensi(
              programId: widget.programId,
              pertemuanKe: pertemuanKe,
              tanggal: selectedDate,
              materi: materiController.text.trim(),
              daftarHadir: daftarHadir,
              catatan: catatanController.text.trim(),
            ),
      );

      if (success && mounted) {
        context.showSuccessSnackBar('Presensi berhasil disimpan');
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showBulkAction() {
    final selectedSantri = ref.read(selectedSantriProvider);
    if (selectedSantri.isEmpty) {
      context.showErrorSnackBar('Pilih santri terlebih dahulu');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => BulkActionBottomSheet(
        programId: widget.programId,
        santriIds: selectedSantri.toList(),
        pertemuanKe: pertemuanKe,
        onStatusUpdate: (status, keterangan) {
          for (var santriId in selectedSantri) {
            ref.read(presensiStatusProvider(santriId).notifier).state = status;
            if (keterangan.isNotEmpty) {
              ref.read(presensiKeteranganProvider(santriId).notifier).state =
                  keterangan;
            }
          }
          context.pop();
        },
      ),
    );
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

  void _toggleSantriSelection(String santriId, bool? selected) {
    final currentSelected = ref.read(selectedSantriProvider);
    if (selected == true) {
      ref.read(selectedSantriProvider.notifier).state = {
        ...currentSelected,
        santriId
      };
    } else {
      currentSelected.remove(santriId);
      ref.read(selectedSantriProvider.notifier).state = {...currentSelected};
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
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

    if (date != null && _isValidDate(date)) {
      setState(() => selectedDate = date);
    }
  }

  // UI Components Build Methods
  @override
  Widget build(BuildContext context) {
    final santriListAsync = ref.watch(santriListProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgramInfo(),
                  verticalSpace(24),
                  _buildPresensiForm(),
                  verticalSpace(24),
                  _buildSantriSection(santriListAsync),
                  verticalSpace(32),
                  _buildSubmitButton(santriListAsync),
                ],
              ),
            ),
          ),
          if (isSubmitting) _buildLoadingOverlay(),
        ],
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

  Widget _buildProgramInfo() {
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
            'Program: ${widget.programId}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.neutral900,
            ),
          ),
          verticalSpace(8),
          Text(
            'Pertemuan ke-$pertemuanKe',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
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

  Widget _buildSantriSection(AsyncValue<List<User>> santriListAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daftar Santri'),
        verticalSpace(16),
        _buildSantriList(santriListAsync),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            final selectedCount = ref.watch(selectedSantriProvider).length;
            return selectedCount > 0
                ? Text(
                    '$selectedCount terpilih',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSantriList(AsyncValue<List<User>> santriListAsync) {
    return santriListAsync.when(
      data: (santriList) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: santriList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => _buildSantriItem(santriList[index]),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.plusJakartaSans(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSantriItem(User santri) {
    return Consumer(
      builder: (context, ref, _) {
        final isSelected =
            ref.watch(selectedSantriProvider).contains(santri.uid);
        final status = ref.watch(presensiStatusProvider(santri.uid));
        final keterangan = ref.watch(presensiKeteranganProvider(santri.uid));

        return Column(
          children: [
            CheckboxListTile(
              value: isSelected,
              onChanged: (checked) =>
                  _toggleSantriSelection(santri.uid, checked),
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
                onKeteranganChanged: (newKeterangan) => _updateSantriPresensi(
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
  }

  Widget _buildSubmitButton(AsyncValue<List<User>> santriListAsync) {
    return santriListAsync.when(
      data: (santriList) {
        final daftarHadir = santriList.map((santri) {
          final status = ref.read(presensiStatusProvider(santri.uid));
          final keterangan = ref.read(presensiKeteranganProvider(santri.uid));
          final presensiStatus = PresensiStatus.values.firstWhere(
            (e) => e.name.toUpperCase() == status,
            orElse: () => PresensiStatus.hadir,
          );

          return SantriPresensi(
            santriId: santri.uid,
            santriName: santri.name,
            status: presensiStatus,
            keterangan: keterangan,
          );
        }).toList();

        return FilledButton(
          onPressed: isSubmitting ? null : () => _confirmSubmit(daftarHadir),
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer(
      builder: (context, ref, _) {
        final selectedCount = ref.watch(selectedSantriProvider).length;
        if (selectedCount == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: _showBulkAction,
          backgroundColor: AppColors.primary,
          label: Text('Update $selectedCount Santri'),
          icon: const Icon(Icons.group_add),
        );
      },
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
}
