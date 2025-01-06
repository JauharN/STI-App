import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';

import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../misc/constants.dart';
import '../../../providers/presensi/admin/edit_presensi_provider.dart';
import '../../../providers/presensi/santri_list_provider.dart';
import '../../../providers/presensi/admin/update_presensi_provider.dart';
import '../../../providers/program/program_provider.dart';
import '../../../widgets/presensi_widget/santri_presensi_card_widget.dart';

class EditPresensiPage extends ConsumerStatefulWidget {
  final String programId;
  final String presensiId;

  const EditPresensiPage({
    super.key,
    required this.programId,
    required this.presensiId,
  });

  @override
  ConsumerState<EditPresensiPage> createState() => _EditPresensiPageState();
}

class _EditPresensiPageState extends ConsumerState<EditPresensiPage> {
  // Controllers
  final materiController = TextEditingController();
  final catatanController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // State variables
  DateTime selectedDate = DateTime.now();
  int pertemuanKe = 1;
  bool isLoading = true;
  bool isSubmitting = false;
  String error = '';

  // Maps untuk menyimpan status presensi santri
  final Map<String, PresensiStatus> santriStatus = {};
  final Map<String, String> santriKeterangan = {};

  // Data presensi yang sedang diedit
  PresensiPertemuan? currentPresensi;

  @override
  void initState() {
    super.initState();
    _loadPresensiData();
  }

  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadPresensiData() async {
    try {
      setState(() => isLoading = true);

      // Load presensi data
      final presensi = await ref.read(
        editPresensiDataProvider(widget.programId, widget.presensiId).future,
      );

      // Initialize form fields
      setState(() {
        currentPresensi = presensi;
        selectedDate = presensi.tanggal;
        pertemuanKe = presensi.pertemuanKe;
        materiController.text = presensi.materi ?? '';
        catatanController.text = presensi.catatan ?? '';

        // Initialize santri status maps
        for (var santri in presensi.daftarHadir) {
          santriStatus[santri.santriId] = santri.status;
          santriKeterangan[santri.santriId] = santri.keterangan ?? '';
        }
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) return false;

    if (materiController.text.isEmpty) {
      context.showErrorSnackBar('Materi tidak boleh kosong');
      return false;
    }

    if (selectedDate.isAfter(DateTime.now())) {
      context.showErrorSnackBar('Tanggal tidak boleh lebih dari hari ini');
      return false;
    }

    return true;
  }

  Future<void> _updatePresensi() async {
    if (!_validateForm()) return;

    try {
      setState(() => isSubmitting = true);

      // Prepare updated daftar hadir
      final updatedDaftarHadir = ref
              .read(santriListProvider(widget.programId))
              .valueOrNull
              ?.map(
                (santri) => SantriPresensi(
                  santriId: santri.uid,
                  santriName: santri.name,
                  status: santriStatus[santri.uid] ?? PresensiStatus.hadir,
                  keterangan: santriKeterangan[santri.uid] ?? '',
                ),
              )
              .toList() ??
          [];

      // Create updated presensi object
      final updatedPresensi = currentPresensi!.copyWith(
        tanggal: selectedDate,
        pertemuanKe: pertemuanKe,
        materi: materiController.text,
        catatan: catatanController.text,
        daftarHadir: updatedDaftarHadir,
        updatedAt: DateTime.now(),
      );

      // Submit update
      final result =
          await ref.read(updatePresensiProvider.notifier).updatePresensi(
                programId: widget.programId,
                presensi: updatedPresensi,
              );

      if (result.isSuccess) {
        if (mounted) {
          context.showSuccessSnackBar('Presensi berhasil diupdate');
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception(result.errorMessage);
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

  // Add preview dialog
  void _showPreviewDialog() {
    if (!_validateForm()) return;

    final daftarHadir = ref
            .read(santriListProvider(widget.programId))
            .valueOrNull
            ?.map(
              (santri) => SantriPresensi(
                santriId: santri.uid,
                santriName: santri.name,
                status: santriStatus[santri.uid] ?? PresensiStatus.hadir,
                keterangan: santriKeterangan[santri.uid] ?? '',
              ),
            )
            .toList() ??
        [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Perubahan'),
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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePresensi();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: _loadPresensiData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Presensi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildProgramInfo() {
    final program = ref.watch(programProvider(widget.programId));

    return program.when(
      data: (programData) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Program: ${programData.nama}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Kelas: ${programData.kelas ?? "Reguler"}'),
              Text('Pengajar: ${programData.pengajarName ?? "-"}'),
              const SizedBox(height: 8),
              Text(
                  'Pertemuan ke-$pertemuanKe dari ${programData.totalPertemuan ?? 8}'),
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

        // Nomor Pertemuan (readonly karena edit)
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
            onPressed: () => Navigator.pop(context),
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
}
