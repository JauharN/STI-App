import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/user_data/user_data_provider.dart';

import 'methods/profile_item.dart';
import 'methods/user_info.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              verticalSpace(20),
              ...userInfo(ref),
              verticalSpace(24 + 24),
              // User Settings
              profileItem(
                'Update Profil',
                icon: Icons.edit_outlined,
                onTap: () {
                  // Navigate to update profile
                },
              ),
              verticalSpace(20),
              profileItem(
                'Ganti Password',
                icon: Icons.lock_outline,
                onTap: () {
                  context.pushNamed('forgot_password');
                },
              ),
              verticalSpace(12),
              const Divider(color: AppColors.neutral700),
              verticalSpace(12),
              // App Settings
              profileItem(
                'Pengaturan Notifikasi',
                icon: Icons.notifications_outlined,
              ),
              verticalSpace(20),
              profileItem(
                'Bahasa',
                icon: Icons.language_outlined,
              ),
              verticalSpace(12),
              const Divider(color: AppColors.neutral700),
              verticalSpace(12),
              // Help & Support
              profileItem(
                'Bantuan',
                icon: Icons.help_outline,
              ),
              verticalSpace(20),
              profileItem(
                'Kebijakan Privasi',
                icon: Icons.privacy_tip_outlined,
              ),
              verticalSpace(20),
              profileItem(
                'Syarat & Ketentuan',
                icon: Icons.description_outlined,
              ),
              verticalSpace(32),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  ref.read(userDataProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              verticalSpace(16),
              Text(
                'Versi 1.0.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
              ),
              verticalSpace(25)
            ],
          ),
        )
      ],
    );
  }
}
