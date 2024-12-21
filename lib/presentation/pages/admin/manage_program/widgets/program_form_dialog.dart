import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../domain/entities/result.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../extensions/extensions.dart';
import '../../../../providers/presensi/admin/manage_program_provider.dart';
import '../../../../providers/repositories/program_repository/program_repository_provider.dart';
import '../../../../providers/user/available_teachers_provider.dart';
import '../../../../widgets/sti_text_field_widget.dart';

class ProgramFormDialog extends ConsumerStatefulWidget {
  final String? programId; // null for add, non-null for edit

  const ProgramFormDialog({super.key, this.programId});

  @override
  ConsumerState<ProgramFormDialog> createState() => _ProgramFormDialogState();
}

class _ProgramFormDialogState extends ConsumerState<ProgramFormDialog> {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final totalMeetingsController = TextEditingController(text: '8');

  // State variables
  List<String> selectedDays = [];
  String? selectedTeacherId;
  String? selectedTeacherName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.programId != null) {
      _loadProgramData();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    totalMeetingsController.dispose();
    super.dispose();
  }

  Future<void> _loadProgramData() async {
    setState(() => isLoading = true);
    try {
      final programRepository = ref.read(programRepositoryProvider);
      final result = await programRepository.getProgramById(widget.programId!);

      if (result case Success(value: final program)) {
        // Populate form fields
        nameController.text = program.nama;
        descriptionController.text = program.deskripsi;
        locationController.text = program.lokasi ?? '';
        totalMeetingsController.text =
            program.totalPertemuan?.toString() ?? '8';
        selectedTeacherId = program.pengajarId;
        selectedTeacherName = program.pengajarName;
        setState(() {
          selectedDays = program.jadwal;
        });
      } else {
        throw Exception('Failed to load program data');
      }
    } catch (e) {
      if (mounted) {
        context
            .showErrorSnackBar('Error loading program data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDays.isEmpty) {
      context.showErrorSnackBar('Pilih minimal satu hari untuk jadwal');
      return;
    }

    setState(() => isLoading = true);
    try {
      final controller = ref.read(manageProgramControllerProvider.notifier);

      final result = widget.programId == null
          ? await controller.createProgram(
              name: nameController.text,
              description: descriptionController.text,
              schedule: selectedDays,
              totalMeetings: int.parse(totalMeetingsController.text),
              location: locationController.text,
              teacherId: selectedTeacherId,
              teacherName: selectedTeacherName,
            )
          : await controller.updateProgram(
              programId: widget.programId!,
              name: nameController.text,
              description: descriptionController.text,
              schedule: selectedDays,
              totalMeetings: int.parse(totalMeetingsController.text),
              location: locationController.text,
              teacherId: selectedTeacherId,
              teacherName: selectedTeacherName,
            );

      if (mounted) {
        if (result.isSuccess) {
          context.showSuccessSnackBar(
            widget.programId == null
                ? 'Program berhasil ditambahkan'
                : 'Program berhasil diupdate',
          );
          Navigator.pop(context, true);
        } else {
          context.showErrorSnackBar(result.errorMessage!);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  widget.programId == null ? 'Tambah Program' : 'Edit Program',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(24),

                // Program name field
                STITextField(
                  labelText: 'Nama Program',
                  controller: nameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama program tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                verticalSpace(16),

                // Description field
                STITextField(
                  labelText: 'Deskripsi Program',
                  controller: descriptionController,
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                verticalSpace(16),

                // Schedule selection
                _buildScheduleSelection(),
                verticalSpace(16),

                // Total meetings field
                STITextField(
                  labelText: 'Total Pertemuan',
                  controller: totalMeetingsController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Total pertemuan tidak boleh kosong';
                    }
                    final number = int.tryParse(value!);
                    if (number == null || number < 1) {
                      return 'Total pertemuan harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                verticalSpace(16),

                // Location field
                STITextField(
                  labelText: 'Lokasi',
                  controller: locationController,
                ),
                verticalSpace(16),

                // Teacher selection
                _buildTeacherSelection(),
                verticalSpace(24),

                // Submit button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.programId == null
                              ? 'Tambah Program'
                              : 'Update Program',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSelection() {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        verticalSpace(8),
        Wrap(
          spacing: 8,
          children: days.map((day) {
            final isSelected = selectedDays.contains(day);
            return FilterChip(
              selected: isSelected,
              label: Text(day),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        if (selectedDays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Pilih minimal satu hari',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeacherSelection() {
    final teachersAsync = ref.watch(availableTeachersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengajar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        verticalSpace(8),
        teachersAsync.when(
          data: (teachers) => DropdownButtonFormField<String>(
            value: selectedTeacherId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            hint: const Text('Pilih Pengajar'),
            items: teachers
                .map((teacher) => DropdownMenuItem(
                      value: teacher.uid,
                      child: Text(teacher.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedTeacherId = value;
                  selectedTeacherName =
                      teachers.firstWhere((t) => t.uid == value).name;
                });
              }
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
