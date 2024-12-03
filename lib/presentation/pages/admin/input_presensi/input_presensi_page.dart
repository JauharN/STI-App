import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../misc/constants.dart';
import '../../../providers/presensi/input_presensi_provider.dart';
import '../../../providers/presensi/santri_list_provider.dart';
import '../../../widgets/presensi/santri_presensi_card_widget.dart';

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
  static const int maxPertemuan = 8;
  // Controllers
  final materiController = TextEditingController();
  final catatanController = TextEditingController();

  // State variables
  DateTime selectedDate = DateTime.now();
  int pertemuanKe = 1;
  bool isSubmitting = false;

  // Map untuk menyimpan status presensi santri
  final Map<String, PresensiStatus> santriStatus = {};
  final Map<String, String> santriKeterangan = {};

  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  // 2. Method untuk menampilkan preview
  void _showPreviewDialog() {
    // Persiapkan data preview
    final List<SantriPresensi> daftarHadir = ref
            .read(santriListProvider(widget.programId))
            .valueOrNull
            ?.map((santri) => SantriPresensi(
                  santriId: santri.uid,
                  santriName: santri.name,
                  status: santriStatus[santri.uid] ?? PresensiStatus.hadir,
                  keterangan: santriKeterangan[santri.uid] ?? '',
                ))
            .toList() ??
        [];

    // Validasi sebelum preview
    if (!ref.read(isValidPresensiInputProvider(
      programId: widget.programId,
      pertemuanKe: pertemuanKe,
      materi: materiController.text,
      daftarHadir: daftarHadir,
    ))) {
      context.showSnackBar('Mohon lengkapi semua data');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Presensi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}'),
              Text('Pertemuan ke-$pertemuanKe'),
              Text('Materi: ${materiController.text}'),
              if (catatanController.text.isNotEmpty)
                Text('Catatan: ${catatanController.text}'),
              const Divider(),
              const Text('Rekap Kehadiran:'),
              ...daftarHadir
                  .map((santri) => Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                            '${santri.santriName}: ${santri.status.name.toUpperCase()}'
                            '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}'),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitPresensi(daftarHadir);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  // Submit dengan validasi
  Future<void> _submitPresensi(List<SantriPresensi> daftarHadir) async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      // Validasi
      if (!ref.read(isValidPresensiInputProvider(
        programId: widget.programId,
        pertemuanKe: pertemuanKe,
        materi: materiController.text,
        daftarHadir: daftarHadir,
      ))) {
        throw Exception('Mohon lengkapi semua data');
      }

      // Submit
      await ref.read(inputPresensiControllerProvider.notifier).submitPresensi(
            programId: widget.programId,
            pertemuanKe: pertemuanKe,
            tanggal: selectedDate,
            materi: materiController.text,
            catatan: catatanController.text,
            daftarHadir: daftarHadir,
          );

      if (mounted) {
        context.showSuccessSnackBar('Presensi berhasil disimpan');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final santriListAsync = ref.watch(santriListProvider(widget.programId));
    final inputController = ref.watch(inputPresensiControllerProvider);

    ref.listen(
      inputPresensiControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            context.showErrorSnackBar(error.toString());
          },
          data: (_) {
            context.showSuccessSnackBar('Presensi berhasil disimpan');
            Navigator.pop(context);
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Input Presensi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Program Section
            _buildProgramInfo(),

            const SizedBox(height: 24),

            // Form Input Section
            _buildPresensiForm(),

            const SizedBox(height: 24),

            // Daftar Santri Section
            Text(
              'Daftar Santri',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            santriListAsync.when(
              data: (santriList) => _buildSantriList(santriList),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Program: ${widget.programId}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Pertemuan ke-$pertemuanKe'),
          ],
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
              firstDate: DateTime(2024, 1, 1),
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
            child: Text(
              DateFormat('dd MMMM yyyy').format(selectedDate),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Nomor Pertemuan
        Row(
          children: [
            const Text('Pertemuan ke: '),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (pertemuanKe > 1) {
                  setState(() => pertemuanKe--);
                }
              },
            ),
            Text('$pertemuanKe'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (pertemuanKe < maxPertemuan) {
                  setState(() => pertemuanKe++);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Materi
        TextField(
          controller: materiController,
          decoration: const InputDecoration(
            labelText: 'Materi',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Catatan
        TextField(
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

  Widget _buildSantriList(List<User> santriList) {
    return ListView.builder(
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
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () => _showPreviewDialog(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: ref.watch(inputPresensiControllerProvider).maybeWhen(
            loading: () => const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            orElse: () => Text(
              'Preview & Simpan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
    );
  }
}
