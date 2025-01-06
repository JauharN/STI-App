import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/presensi/santri_presensi.dart';
import '../../../misc/constants.dart';
import '../../../providers/presensi/admin/input_presensi_provider.dart';
import '../../../providers/presensi/santri_list_provider.dart';
import '../../../widgets/presensi_widget/bulk_action_bottom_sheet_widget.dart';
import '../../../widgets/presensi_widget/santri_presensi_card_widget.dart';

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
  static const int maxPertemuan = 8;
  DateTime selectedDate = DateTime.now();
  int pertemuanKe = 1;
  bool isSubmitting = false;
  final Set<String> selectedSantriIds = {};

  // Maps untuk menyimpan status presensi santri
  final Map<String, PresensiStatus> santriStatus = {};
  final Map<String, String> santriKeterangan = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  @override
  void dispose() {
    materiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  // Initialize methods
  void _initializeDefaults() {
    final santriList = ref.read(santriListProvider(widget.programId));
    santriList.whenData((list) {
      for (var santri in list) {
        santriStatus[santri.uid] = PresensiStatus.hadir;
      }
    });
  }

  // Validation methods
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

  // Action methods
  Future<void> _confirmSubmit(List<SantriPresensi> daftarHadir) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Submit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}'),
              Text('Pertemuan ke-$pertemuanKe'),
              Text('Materi: ${materiController.text}'),
              if (catatanController.text.isNotEmpty)
                Text('Catatan: ${catatanController.text}'),
              const Divider(),
              const Text('Daftar Hadir:'),
              ...daftarHadir.map((santri) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('${santri.santriName}: ${santri.status.label}'
                        '${santri.keterangan?.isNotEmpty == true ? " (${santri.keterangan})" : ""}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
    if (!_validateForm()) return;

    setState(() => isSubmitting = true);

    try {
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
      ),
    );
  }

  // Build methods
  @override
  Widget build(BuildContext context) {
    final santriListAsync = ref.watch(santriListProvider(widget.programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
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
              _buildSantriSection(santriListAsync),
              const SizedBox(height: 32),
              _buildSubmitButton(santriListAsync),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedSantriIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showBulkAction,
              label: Text('Update ${selectedSantriIds.length} Santri'),
              icon: const Icon(Icons.group_add),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Input Presensi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
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
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildPertemuanCounter(),
        const SizedBox(height: 16),
        _buildMateriInput(),
        const SizedBox(height: 16),
        _buildCatatanInput(),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
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
        child: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
      ),
    );
  }

  Widget _buildPertemuanCounter() {
    return Row(
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
    );
  }

  Widget _buildMateriInput() {
    return TextFormField(
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
    );
  }

  Widget _buildCatatanInput() {
    return TextFormField(
      controller: catatanController,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSantriSection(AsyncValue<List<User>> santriListAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Santri',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSantriList(santriListAsync),
      ],
    );
  }

  Widget _buildSantriList(AsyncValue<List<User>> santriListAsync) {
    return santriListAsync.when(
      data: (santriList) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: santriList.length,
        itemBuilder: (context, index) {
          final santri = santriList[index];
          return Column(
            children: [
              CheckboxListTile(
                value: selectedSantriIds.contains(santri.uid),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      selectedSantriIds.add(santri.uid);
                    } else {
                      selectedSantriIds.remove(santri.uid);
                    }
                  });
                },
                title: Text(santri.name),
                subtitle: SantriPresensiCard(
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
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildSubmitButton(AsyncValue<List<User>> santriListAsync) {
    return santriListAsync.when(
      data: (santriList) {
        final daftarHadir = santriList
            .map((santri) => SantriPresensi(
                  santriId: santri.uid,
                  santriName: santri.name,
                  status: santriStatus[santri.uid] ?? PresensiStatus.hadir,
                  keterangan: santriKeterangan[santri.uid] ?? '',
                ))
            .toList();

        return ElevatedButton(
          onPressed: isSubmitting ? null : () => _confirmSubmit(daftarHadir),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
              : Text(
                  'Submit Presensi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
