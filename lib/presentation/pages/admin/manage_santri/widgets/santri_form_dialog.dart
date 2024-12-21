import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../domain/entities/result.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../extensions/extensions.dart';

import '../../../../providers/presensi/admin/manage_santri_provider.dart';
import '../../../../providers/program/available_programs_provider.dart';
import '../../../../providers/repositories/user_repository/user_repository_provider.dart';
import '../../../../widgets/sti_text_field_widget.dart';

class SantriFormDialog extends ConsumerStatefulWidget {
  final String? santriId; // null for add, non-null for edit

  const SantriFormDialog({super.key, this.santriId});

  @override
  ConsumerState<SantriFormDialog> createState() => _SantriFormDialogState();
}

class _SantriFormDialogState extends ConsumerState<SantriFormDialog> {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); // Only for new santri
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // State variables
  File? profileImage;
  DateTime? selectedDate;
  List<String> selectedPrograms = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.santriId != null) {
      // Load existing santri data if editing
      _loadSantriData();
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Validasi nomor telepon
  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) return null; // Optional field

    final phoneRegex = RegExp(r'^\+?[\d-]{10,}$');
    if (!phoneRegex.hasMatch(value!)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  // Validasi nama
  String? _validateName(String? value) {
    if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
    if (value!.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  // Load existing santri data
  Future<void> _loadSantriData() async {
    setState(() => isLoading = true);
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.getUser(uid: widget.santriId!);

      if (result case Success(value: final user)) {
        // Populate form fields
        nameController.text = user.name;
        phoneController.text = user.phoneNumber ?? '';
        addressController.text = user.address ?? '';
        selectedDate = user.dateOfBirth;

        // Load enrolled programs
        final programs =
            await userRepository.getUserPrograms(uid: widget.santriId!);
        if (programs case Success(value: final programList)) {
          setState(() {
            selectedPrograms = programList;
          });
        }
      } else {
        throw Exception('Failed to load santri data');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error loading santri data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          profileImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error picking image: ${e.toString()}');
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      setState(() => isLoading = true);

      final userRepository = ref.read(userRepositoryProvider);
      String? photoUrl;

      if (widget.santriId != null) {
        final currentUser = await userRepository.getUser(uid: widget.santriId!);
        if (currentUser case Success(value: final user)) {
          final uploadResult = await userRepository.uploadProfilePicture(
            user: user,
            imageFile: imageFile,
          );
          if (uploadResult case Success(value: final updatedUser)) {
            photoUrl = updatedUser.photoUrl;
          }
        }
      }

      return photoUrl;
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Gagal mengupload foto: ${e.toString()}');
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Handle form submission
  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      String? photoUrl;

      // Upload foto jika ada
      if (profileImage != null) {
        photoUrl = await _uploadProfileImage(profileImage!);
      }

      final controller = ref.read(manageSantriControllerProvider.notifier);
      final result = widget.santriId == null
          ? await controller.createSantri(
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text,
              photoUrl: photoUrl, // Gunakan URL foto yang baru diupload
              phoneNumber: phoneController.text,
              address: addressController.text,
              dateOfBirth: selectedDate,
              programIds: selectedPrograms,
            )
          : await controller.updateSantri(
              santriId: widget.santriId!,
              name: nameController.text,
              photoUrl: photoUrl, // Gunakan URL foto yang baru diupload
              phoneNumber: phoneController.text,
              address: addressController.text,
              dateOfBirth: selectedDate,
              programIds: selectedPrograms,
            );

      if (mounted) {
        if (result.isSuccess) {
          context.showSuccessSnackBar(
            widget.santriId == null
                ? 'Santri berhasil ditambahkan'
                : 'Santri berhasil diupdate',
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
                  widget.santriId == null ? 'Tambah Santri' : 'Edit Santri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(24),

                // Photo selection
                _buildPhotoSelection(),
                verticalSpace(16),

                // Name field
                STITextField(
                  labelText: 'Nama Lengkap',
                  controller: nameController,
                  validator: _validateName,
                ),
                verticalSpace(16),

                // Email field (only for new santri)
                if (widget.santriId == null) ...[
                  STITextField(
                    labelText: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  verticalSpace(16),

                  // Password field (only for new santri)
                  STITextField(
                    labelText: 'Password',
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value!.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(16),
                ],

                // Phone field
                STITextField(
                  labelText: 'No. Telepon',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                verticalSpace(16),

                // Address field
                STITextField(
                  labelText: 'Alamat',
                  controller: addressController,
                  maxLines: 2,
                ),
                verticalSpace(16),

                // Date of birth
                _buildDatePicker(),
                verticalSpace(16),

                // Program selection
                _buildProgramSelection(),
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
                          widget.santriId == null
                              ? 'Tambah Santri'
                              : 'Update Santri',
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

  Widget _buildPhotoSelection() {
    return Center(
      child: Stack(
        children: [
          // Profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral100,
              image: profileImage != null
                  ? DecorationImage(
                      image: FileImage(profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileImage == null
                ? const Icon(Icons.person,
                    size: 50, color: AppColors.neutral400)
                : null,
          ),
          // Camera icon
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tanggal Lahir',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedDate != null
              ? formatDate(selectedDate!)
              : 'Pilih tanggal lahir',
        ),
      ),
    );
  }

  Widget _buildProgramSelection() {
    final programsAsync = ref.watch(availableProgramsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        verticalSpace(8),
        programsAsync.when(
          data: (programs) => Wrap(
            spacing: 8,
            children: programs.map((program) {
              final isSelected = selectedPrograms.contains(program.id);
              return FilterChip(
                selected: isSelected,
                label: Text(program.nama),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedPrograms.add(program.id);
                    } else {
                      selectedPrograms.remove(program.id);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
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

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
