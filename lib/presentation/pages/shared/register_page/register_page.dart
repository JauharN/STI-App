import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../extensions/extensions.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/program/available_programs_provider.dart'; // Tambahan untuk program selection
import '../../../providers/user_data/user_data_provider.dart';
import '../../../utils/exception.dart';
import '../../../utils/rate_limit_exception.dart';
import '../../../widgets/sti_text_field_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // FocusNodes
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final addressFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // State variables
  DateTime? selectedDate;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  bool isRegistered = false;

  // Tambahan untuk program selection
  List<String> selectedPrograms = [];

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();

    // Dispose focus nodes
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    addressFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  // PART 2: Validation & Helper Methods (Line 101-200)

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return '$fieldName terlalu pendek';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    final phoneRegex = RegExp(r'^\+?[\d\-\s]{10,13}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  // Validasi program selaras dengan repository rules
  String? _validateProgramSelection() {
    if (selectedPrograms.isEmpty) {
      return 'Pilih minimal 1 program';
    }
    if (selectedPrograms.length > 3) {
      return 'Maksimal pilih 3 program';
    }

    // Validasi kombinasi program yang tidak diperbolehkan
    if (selectedPrograms.contains('GMM') && selectedPrograms.contains('IFIS')) {
      return 'Program GMM dan IFIS tidak dapat diambil bersamaan';
    }

    return null;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || isLoading) return;

    // Validasi program selection
    final programError = _validateProgramSelection();
    if (programError != null) {
      context.showErrorSnackBar(programError);
      return;
    }

    // Validasi tanggal lahir wajib
    if (selectedDate == null) {
      context.showErrorSnackBar('Tanggal lahir harus diisi');
      return;
    }

    setState(() => isLoading = true);

    try {
      debugPrint('Starting registration process...');
      debugPrint('Email: ${emailController.text.trim()}');
      debugPrint('Name: ${nameController.text.trim()}');

      await ref.read(userDataProvider.notifier).register(
            email: emailController.text.trim(),
            password: passwordController.text,
            name: nameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            address: addressController.text.trim(),
            dateOfBirth: selectedDate,
            selectedPrograms: selectedPrograms,
          );

      if (mounted) {
        // Tunggu sebentar untuk memastikan data tersimpan
        await Future.delayed(const Duration(milliseconds: 500));
        context.goNamed('login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat registrasi';

        if (e is LoginException || e is FormatException) {
          errorMessage = e.toString();
        } else if (e is RateLimitException) {
          errorMessage = e.message;
        }

        debugPrint('Registration error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // PART 4: UI Building Methods Part 1 (Line 301-400)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
            onPressed: () => context.canPop()
                ? Navigator.of(context).pop()
                : context.goNamed('login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  verticalSpace(32),
                  _buildPersonalInfoFields(),
                  verticalSpace(16),
                  _buildContactFields(),
                  verticalSpace(16),
                  _buildProgramSelection(),
                  verticalSpace(16),
                  _buildPasswordFields(),
                  verticalSpace(32),
                  _buildRegisterButton(),
                  verticalSpace(16),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Akun',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        verticalSpace(8),
        Text(
          'Lengkapi data diri Anda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        STITextField(
          key: const ValueKey('nama'),
          labelText: 'Nama Lengkap',
          controller: nameController,
          focusNode: nameFocusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
          validator: (value) => _validateRequired(value, 'Nama'),
          prefixIcon:
              const Icon(Icons.person_outline, color: AppColors.neutral600),
        ),
        verticalSpace(16),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Lahir',
              prefixIcon:
                  const Icon(Icons.calendar_today, color: AppColors.neutral600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                  : 'Pilih tanggal lahir',
              style: GoogleFonts.plusJakartaSans(
                color: selectedDate != null
                    ? AppColors.neutral800
                    : AppColors.neutral600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        STITextField(
          key: const ValueKey('email'),
          labelText: 'Email',
          controller: emailController,
          focusNode: emailFocusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => phoneFocusNode.requestFocus(),
          validator: _validateEmail,
          prefixIcon:
              const Icon(Icons.email_outlined, color: AppColors.neutral600),
        ),
        verticalSpace(16),
        STITextField(
          key: const ValueKey('phone'),
          labelText: 'Nomor Telepon',
          controller: phoneController,
          focusNode: phoneFocusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => addressFocusNode.requestFocus(),
          validator: _validatePhone,
          prefixIcon:
              const Icon(Icons.phone_outlined, color: AppColors.neutral600),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
        ),
        verticalSpace(16),
        STITextField(
          key: const ValueKey('address'),
          labelText: 'Alamat',
          controller: addressController,
          focusNode: addressFocusNode,
          maxLines: 2,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
          validator: (value) => _validateRequired(value, 'Alamat'),
          prefixIcon: const Icon(Icons.location_on_outlined,
              color: AppColors.neutral600),
        ),
      ],
    );
  }

  // PART 5: UI Building Methods Part 2 (Line 401-482)

  Widget _buildProgramSelection() {
    // Gunakan available_programs_provider untuk mendapatkan list program
    final availableProgramsAsync = ref.watch(availableProgramsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Program',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        verticalSpace(8),
        availableProgramsAsync.when(
          data: (programs) => Wrap(
            spacing: 8,
            runSpacing: 8,
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Gagal memuat daftar program'),
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        STITextField(
          key: const ValueKey('password'),
          labelText: 'Password',
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
          validator: _validatePassword,
          prefixIcon:
              const Icon(Icons.lock_outline, color: AppColors.neutral600),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.neutral600,
            ),
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        verticalSpace(16),
        STITextField(
          key: const ValueKey('confirmPassword'),
          labelText: 'Konfirmasi Password',
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          validator: _validateConfirmPassword,
          prefixIcon:
              const Icon(Icons.lock_outline, color: AppColors.neutral600),
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.neutral600,
            ),
            onPressed: () => setState(
                () => obscureConfirmPassword = !obscureConfirmPassword),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
              'Daftar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.neutral600,
          ),
        ),
        TextButton(
          onPressed: () => context.canPop()
              ? Navigator.of(context).pop()
              : context.goNamed('login'),
          child: Text(
            'Masuk',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
