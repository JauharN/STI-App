import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/router/router_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../utils/storage_helper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _setupAnimation();

      // Delay minimal untuk splash
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Get stored session
      final sessionData = await StorageHelper.getUserSession();
      final isLoggedIn = sessionData?['isLoggedIn'] as bool? ?? false;

      if (isLoggedIn) {
        final email = sessionData?['email'] as String?;
        final password = sessionData?['password'] as String?;

        if (email != null && password != null) {
          debugPrint('Attempting auto-login for: $email');

          // Auto login
          await ref.read(userDataProvider.notifier).login(
                email: email,
                password: password,
              );

          if (!mounted) return;

          // Check login result
          final userState = ref.read(userDataProvider);
          if (userState is AsyncData && userState.value != null) {
            ref.read(routerProvider).goNamed('main');
            return;
          } else {
            // Clear invalid session
            await StorageHelper.clearUserSession();
          }
        }
      }

      if (!mounted) return;

      // Check first time user
      final isFirstTime =
          await StorageHelper.getData<bool>('isFirstTime') ?? true;
      if (isFirstTime) {
        ref.read(routerProvider).goNamed('onboarding');
      } else {
        ref.read(routerProvider).goNamed('login');
      }
    } catch (e) {
      debugPrint('Error in splash screen: $e');
      if (mounted) {
        ref.read(routerProvider).goNamed('login');
      }
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF395C03),
                      Color(0xFF9ABA01),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              verticalSpace(24),
              // App Name
              Text(
                'STI App',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              verticalSpace(8),
              // Slogan
              Text(
                "Digital Solution for Qur'an Memorization",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
