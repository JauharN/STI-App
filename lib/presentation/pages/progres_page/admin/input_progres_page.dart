import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_hafalan_provider.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/progres_hafalan_widget/progres_hafalan_form_card.dart';

class InputProgresPage extends ConsumerStatefulWidget {
  const InputProgresPage({super.key});

  @override
  ConsumerState<InputProgresPage> createState() => _InputProgresPageState();
}

class _InputProgresPageState extends ConsumerState<InputProgresPage> {
  String? _selectedProgramId;
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
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Input Progres Hafalan',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Selection
            DropdownButtonFormField<String>(
              value: _selectedProgramId,
              decoration: const InputDecoration(
                labelText: 'Pilih Program',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'TAHFIDZ', child: Text('Tahfidz')),
                DropdownMenuItem(value: 'GMM', child: Text('GMM')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProgramId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            if (_selectedProgramId != null) ...[
              ProgresHafalanFormCard(
                programId: _selectedProgramId!,
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
                onDateChanged: (date) => setState(() => _selectedDate = date),
                onJuzChanged: (value) => setState(() => _juz = value),
                onHalamanChanged: (value) => setState(() => _halaman = value),
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
                onCatatanChanged: (value) => setState(() => _catatan = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleSubmit(user.uid),
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
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String userId) async {
    // Validasi input
    if (_selectedProgramId == null || _selectedDate == null) {
      context.showErrorSnackBar('Program dan tanggal harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(progresHafalanNotifierProvider.notifier).createProgres(
            userId: userId,
            programId: _selectedProgramId!,
            tanggal: _selectedDate!,
            // TAHFIDZ
            juz: _juz != null ? int.tryParse(_juz!) : null,
            halaman: _halaman != null ? int.tryParse(_halaman!) : null,
            ayat: _ayat != null ? int.tryParse(_ayat!) : null,
            surah: _surah,
            statusPenilaian: _statusPenilaian,
            // GMM
            iqroLevel: _iqroLevel,
            iqroHalaman:
                _iqroHalaman != null ? int.tryParse(_iqroHalaman!) : null,
            statusIqro: _statusIqro,
            mutabaahTarget: _mutabaahTarget,
            statusMutabaah: _statusMutabaah,
            catatan: _catatan,
          );

      if (mounted) {
        context.showSuccessSnackBar('Berhasil menyimpan progres');
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
