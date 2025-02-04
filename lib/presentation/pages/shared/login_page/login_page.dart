import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/router/router_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../utils/rate_limit_exception.dart';
import '../../../utils/rate_limit_helper.dart';
import '../../../widgets/sti_text_field_widget.dart';

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
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final bool _isDebugMode = true;
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;
  bool isLoginAttempted = false;

  late final RateLimitHelper _rateLimitHelper;

  @override
  void initState() {
    super.initState();
    _rateLimitHelper = RateLimitHelper();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      _showErrorSnackBar('Email tidak boleh kosong');
      emailFocusNode.requestFocus();
      return false;
    }

    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackBar('Format email tidak valid');
      emailFocusNode.requestFocus();
      return false;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('Password tidak boleh kosong');
      passwordFocusNode.requestFocus();
      return false;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password minimal 6 karakter');
      passwordFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs() || isLoading) return;

    setState(() => isLoading = true);
    isLoginAttempted = true;

    try {
      if (_isDebugMode) {
        debugPrint('Attempting login with:');
        debugPrint('Email: ${emailController.text.trim()}');
        // Don't log password in production
        debugPrint('Password length: ${passwordController.text.length}');
      }

      await ref.read(userDataProvider.notifier).login(
            email: emailController.text.trim(),
            password: passwordController.text,
            rememberMe: rememberMe,
          );
    } on RateLimitException catch (e) {
      if (_isDebugMode) debugPrint('Rate limit exception: ${e.message}');
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (_isDebugMode) debugPrint('Login error: $e');
      if (mounted && isLoginAttempted) {
        _showErrorSnackBar(_getFormattedErrorMessage(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoginAttempted = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.neutral100,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  String _getFormattedErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    if (errorLower.contains('network-request-failed')) {
      return 'Koneksi gagal. Periksa internet Anda';
    }
    if (errorLower.contains('user-not-found')) {
      return 'Email tidak terdaftar';
    }
    if (errorLower.contains('wrong-password') ||
        errorLower.contains('invalid-credential')) {
      return 'Password salah';
    }
    if (errorLower.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat';
    }
    if (errorLower.contains('invalid-email')) {
      return 'Format email tidak valid';
    }
    return 'Terjadi kesalahan. Silakan coba lagi';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (!mounted) return;

        if (next is AsyncData && next.value != null) {
          // User logged in successfully
          debugPrint('Login successful, routing to main page');
          ref.read(routerProvider).goNamed('main');
        } else if (next is AsyncError) {
          final errorMessage = switch (next.error.toString().toLowerCase()) {
            String e when e.contains('wrong-password') =>
              'Password yang Anda masukkan salah',
            String e when e.contains('user-not-found') =>
              'Email tidak terdaftar',
            String e when e.contains('invalid-email') =>
              'Format email tidak valid',
            String e when e.contains('network-request-failed') =>
              'Koneksi gagal. Periksa internet Anda',
            String e when e.contains('too-many-requests') =>
              'Terlalu banyak percobaan login, silakan tunggu beberapa saat',
            _ => 'Terjadi kesalahan, silakan coba lagi',
          };
          _showErrorSnackBar(errorMessage);
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                verticalSpace(32),
                _buildWelcomeText(),
                verticalSpace(32),
                _buildEmailField(),
                verticalSpace(16),
                _buildPasswordField(),
                verticalSpace(16),
                _buildRememberMeSection(),
                verticalSpace(32),
                _buildLoginButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
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
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildEmailField() {
    return STITextField(
      labelText: 'Email',
      controller: emailController,
      focusNode: emailFocusNode,
      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.neutral600),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
    );
  }

  Widget _buildPasswordField() {
    return STITextField(
      labelText: 'Password',
      controller: passwordController,
      focusNode: passwordFocusNode,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.neutral600),
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.neutral600,
        ),
        onPressed: () => setState(() => obscurePassword = !obscurePassword),
      ),
    );
  }

  Widget _buildRememberMeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: rememberMe,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => rememberMe = value ?? false);
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
        TextButton(
          onPressed: isLoading
              ? null
              : () => ref.read(routerProvider).goNamed('forgot_password'),
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
    );
  }

  Widget _buildLoginButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final userState = ref.watch(userDataProvider);

        return Column(
          children: [
            ElevatedButton(
              onPressed:
                  isLoading || _rateLimitHelper.isLimited ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: AppColors.neutral300,
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
                      'Masuk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
            verticalSpace(16),
            OutlinedButton(
              onPressed: userState is AsyncLoading || isLoading
                  ? null
                  : () {
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
          ],
        );
      },
    );
  }
}
