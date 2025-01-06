import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../extensions/extensions.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/router/router_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/sti_text_field_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  DateTime? selectedDate;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
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

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = ref.read(userDataProvider.notifier);
      await userProvider.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        dateOfBirth: selectedDate,
      );

      // Tampilkan pesan sukses dan arahkan ke halaman login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
      );
      ref.read(routerProvider).goNamed('login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.length < 10 || value.length > 13) {
      return 'Nomor telepon harus 10-13 digit';
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

  @override
  Widget build(BuildContext context) {
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (next is AsyncError) {
          context.showSnackBar(next.error.toString());
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.neutral900,
          ),
          onPressed: () {
            if (context.canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed('login');
            }
          },
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
                verticalSpace(32),

                // Name Field
                STITextField(
                  labelText: 'Nama Lengkap',
                  controller: nameController,
                  validator: (value) => _validateRequired(value, 'Nama'),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Email Field
                STITextField(
                  labelText: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Phone Field
                STITextField(
                  labelText: 'Nomor Telepon',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.neutral600),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                ),
                verticalSpace(16),

                // Date of Birth Field
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.neutral600),
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
                verticalSpace(16),

                // Address Field
                STITextField(
                  labelText: 'Alamat',
                  controller: addressController,
                  maxLines: 2,
                  validator: (value) => _validateRequired(value, 'Alamat'),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.neutral600),
                ),
                verticalSpace(16),

                // Password Field
                STITextField(
                  labelText: 'Password',
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: _validatePassword,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.neutral600),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.neutral600),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                verticalSpace(16),

                // Confirm Password Field
                STITextField(
                  labelText: 'Konfirmasi Password',
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.neutral600),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.neutral600),
                    onPressed: () => setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword),
                  ),
                ),

                verticalSpace(32),

                // Register Button
                ElevatedButton(
                  onPressed: isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : Text(
                          'Daftar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                verticalSpace(16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.neutral600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed('login'),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
