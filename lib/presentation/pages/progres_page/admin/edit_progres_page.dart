import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_detail_provider.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_hafalan_provider.dart';

import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/progres_hafalan_widget/progres_hafalan_form_card.dart';

class EditProgresPage extends ConsumerStatefulWidget {
  final String id;

  const EditProgresPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<EditProgresPage> createState() => _EditProgresPageState();
}

class _EditProgresPageState extends ConsumerState<EditProgresPage> {
  DateTime? _selectedDate;
  // TAHFIDZ fields
  String? _juz;
  String? _halaman;
  String? _ayat;
  String? _surah;
  String? _statusPenilaian;
  // GMM fields
  String? _iqroLevel;
  String? _iqroHalaman;
  String? _statusIqro;
  String? _mutabaahTarget;
  String? _statusMutabaah;
  // Common
  String? _catatan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(progresDetailNotifierProvider.notifier)
          .getLatestProgres(widget.id);
    });
  }

  void _initializeData(ProgresHafalan progres) {
    setState(() {
      _selectedDate = progres.tanggal;
      // TAHFIDZ
      _juz = progres.juz?.toString();
      _halaman = progres.halaman?.toString();
      _ayat = progres.ayat?.toString();
      _surah = progres.surah;
      _statusPenilaian = progres.statusPenilaian;
      // GMM
      _iqroLevel = progres.iqroLevel;
      _iqroHalaman = progres.iqroHalaman?.toString();
      _statusIqro = progres.statusIqro;
      _mutabaahTarget = progres.mutabaahTarget;
      _statusMutabaah = progres.statusMutabaah;
      // Common
      _catatan = progres.catatan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Progres Hafalan',
          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: ref.watch(progresDetailNotifierProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(progresDetailNotifierProvider.notifier)
                          .getLatestProgres(widget.id);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
            data: (progres) {
              if (progres == null) {
                return const Center(child: Text('Data tidak ditemukan'));
              }

              // Initialize form data if not yet initialized
              if (_selectedDate == null) {
                _initializeData(progres);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProgresHafalanFormCard(
                      programId: progres.programId,
                      selectedDate: _selectedDate,
                      juz: _juz,
                      halaman: _halaman,
                      ayat: _ayat,
                      surah: _surah,
                      statusPenilaian: _statusPenilaian,
                      iqroLevel: _iqroLevel,
                      iqroHalaman: _iqroHalaman,
                      statusIqro: _statusIqro,
                      mutabaahTarget: _mutabaahTarget,
                      statusMutabaah: _statusMutabaah,
                      catatan: _catatan,
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                      onJuzChanged: (value) => setState(() => _juz = value),
                      onHalamanChanged: (value) =>
                          setState(() => _halaman = value),
                      onAyatChanged: (value) => setState(() => _ayat = value),
                      onSurahChanged: (value) => setState(() => _surah = value),
                      onStatusPenilaianChanged: (value) =>
                          setState(() => _statusPenilaian = value),
                      onIqroLevelChanged: (value) =>
                          setState(() => _iqroLevel = value),
                      onIqroHalamanChanged: (value) =>
                          setState(() => _iqroHalaman = value),
                      onStatusIqroChanged: (value) =>
                          setState(() => _statusIqro = value),
                      onMutabaahTargetChanged: (value) =>
                          setState(() => _mutabaahTarget = value),
                      onStatusMutabaahChanged: (value) =>
                          setState(() => _statusMutabaah = value),
                      onCatatanChanged: (value) =>
                          setState(() => _catatan = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSubmit(progres, user.uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Future<void> _handleSubmit(ProgresHafalan oldProgres, String userId) async {
    if (_selectedDate == null) {
      context.showErrorSnackBar('Tanggal harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProgres = ProgresHafalan(
        id: oldProgres.id,
        userId: oldProgres.userId,
        programId: oldProgres.programId,
        tanggal: _selectedDate!,
        // TAHFIDZ
        juz: _juz != null ? int.tryParse(_juz!) : null,
        halaman: _halaman != null ? int.tryParse(_halaman!) : null,
        ayat: _ayat != null ? int.tryParse(_ayat!) : null,
        surah: _surah,
        statusPenilaian: _statusPenilaian,
        // GMM
        iqroLevel: _iqroLevel,
        iqroHalaman: _iqroHalaman != null ? int.tryParse(_iqroHalaman!) : null,
        statusIqro: _statusIqro,
        mutabaahTarget: _mutabaahTarget,
        statusMutabaah: _statusMutabaah,
        catatan: _catatan,
        createdAt: oldProgres.createdAt,
        createdBy: oldProgres.createdBy,
      );

      await ref
          .read(progresHafalanNotifierProvider.notifier)
          .updateProgres(updatedProgres);

      if (mounted) {
        context.showSuccessSnackBar('Berhasil mengupdate progres');
        GoRouter.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
