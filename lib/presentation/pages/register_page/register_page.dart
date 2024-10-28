import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/router/router_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/sti_text_field_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedRole = 'santri'; // Default role

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen untuk navigasi setelah register
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (next is AsyncData && next.value != null) {
          ref.read(routerProvider).goNamed('main');
        } else if (next is AsyncError) {
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
              context.goNamed('login');
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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

              // Name TextField
              STITextField(
                labelText: 'Nama Lengkap',
                controller: nameController,
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.neutral600),
              ),

              verticalSpace(16),

              // Email TextField
              STITextField(
                labelText: 'Email',
                controller: emailController,
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.neutral600),
                keyboardType: TextInputType.emailAddress,
              ),

              verticalSpace(16),

              // Password TextField
              STITextField(
                labelText: 'Password',
                controller: passwordController,
                obscureText: true,
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.neutral600),
              ),

              verticalSpace(16),

              // Confirm Password TextField
              STITextField(
                labelText: 'Konfirmasi Password',
                controller: confirmPasswordController,
                obscureText: true,
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.neutral600),
              ),

              verticalSpace(16),

              // Role Selection
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline,
                        color: AppColors.neutral600),
                    horizontalSpace(12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'santri',
                              child: Text('Santri'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              verticalSpace(32),

              // Register Button
              Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(userDataProvider);

                  return ElevatedButton(
                    onPressed: userState is AsyncLoading
                        ? null
                        : () {
                            // Validasi input
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              context.showSnackBar('Password tidak sama');
                              return;
                            }

                            // Proses register
                            ref.read(userDataProvider.notifier).register(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  role: selectedRole,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: userState is AsyncLoading
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
                },
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
    );
  }
}
