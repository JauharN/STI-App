import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/user_data/user_data_provider.dart';

class UnauthorizedPage extends ConsumerWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userDataProvider).valueOrNull;
    final userRole = currentUser?.role ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => context.canPop()
              ? Navigator.of(context).pop()
              : context.goNamed('main'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: AppColors.error,
              ),
              verticalSpace(24),
              Text(
                'Akses Terbatas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(16),
              Text(
                'Maaf, Anda tidak memiliki akses ke halaman ini.\nRole Anda saat ini: $userRole',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace(32),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('main'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Kembali ke Beranda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              verticalSpace(16),
              if (currentUser != null) ...[
                TextButton(
                  onPressed: () async {
                    await ref.read(userDataProvider.notifier).logout();
                    if (context.mounted) {
                      context.goNamed('login');
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
