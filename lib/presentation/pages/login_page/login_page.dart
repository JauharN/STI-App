import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';
import '../../../domain/entities/user.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/router/router_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/sti_text_field_widget.dart';

class LoginConstants {
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = LoginConstants.maxRetries,
    int timeoutSeconds = LoginConstants.timeoutSeconds,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation().timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw TimeoutException('Operation timed out');
          },
        );
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
                'Operation failed after $maxRetries attempts: ${e.toString()}');
          }
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (emailController.text.isEmpty) {
      context.showErrorSnackBar('Email tidak boleh kosong');
      return false;
    }
    if (!emailRegex.hasMatch(emailController.text)) {
      context.showErrorSnackBar('Format email tidak valid');
      return false;
    }
    if (passwordController.text.isEmpty) {
      context.showErrorSnackBar('Password tidak boleh kosong');
      return false;
    }
    if (passwordController.text.length < 6) {
      context.showErrorSnackBar('Password minimal 6 karakter');
      return false;
    }
    return true;
  }

  void _handleRoleBasedRouting(UserRole? role) {
    if (!mounted) return;

    switch (role) {
      case UserRole.superAdmin:
        ref.read(routerProvider).goNamed('user-management');
        break;
      case UserRole.admin:
        ref.read(routerProvider).goNamed('manage-presensi');
        break;
      case UserRole.santri:
        ref.read(routerProvider).goNamed('main');
        break;
      default:
        ref.read(routerProvider).goNamed('login');
    }
  }

  void _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);
    try {
      await ref.read(userDataProvider.notifier).login(
            email: emailController.text,
            password: passwordController.text,
            rememberMe: rememberMe,
          );

      final userRole = ref.read(userDataProvider).value?.role;
      _handleRoleBasedRouting(userRole);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (next is AsyncData && next.value != null) {
          _handleRoleBasedRouting(next.value!.role);
        } else if (next is AsyncError) {
          final errorMessage = switch (next.error.toString()) {
            String e when e.contains('wrong-password') =>
              'Password yang Anda masukkan salah',
            String e when e.contains('user-not-found') =>
              'Email tidak terdaftar',
            String e when e.contains('invalid-email') =>
              'Format email tidak valid',
            String e when e.contains('network-request-failed') =>
              'Koneksi gagal. Periksa internet Anda',
            _ => next.error.toString(),
          };
          context.showErrorSnackBar(errorMessage);
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo dan titik
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-4, -16),
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              verticalSpace(32),

              // Welcome Text
              Text(
                'Assalamu\'alaikum,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              verticalSpace(8),
              Text(
                'Silakan masuk untuk melanjutkan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.neutral600,
                ),
              ),

              verticalSpace(32),

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
                obscureText: obscurePassword,
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.neutral600),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.neutral600,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              verticalSpace(16),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Remember Me
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      horizontalSpace(8),
                      Text(
                        'Ingat Saya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      ref.read(routerProvider).goNamed('forgot_password');
                    },
                    child: Text(
                      'Lupa Password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              verticalSpace(32),

              // Sign In Button
              Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(userDataProvider);

                  return ElevatedButton(
                    onPressed: userState is AsyncLoading ? null : _handleLogin,
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
                            'Masuk',
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

              // Register Button
              OutlinedButton(
                onPressed: () {
                  ref.read(routerProvider).goNamed('register');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Daftar Akun',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
