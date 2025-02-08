import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/profile_widget/profile_item_widget.dart';
import '../../../widgets/profile_widget/user_info_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userDataProvider).value?.role;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              verticalSpace(20),
              // User info section menggunakan widget terpisah
              ...userInfo(ref),
              verticalSpace(24 + 24),

              // Menu items based on role
              if (userRole == 'superAdmin') ...[
                _buildSuperAdminMenu(context),
              ] else if (userRole == 'admin') ...[
                _buildAdminMenu(context),
              ],

              // Common menu items
              _buildCommonMenuItems(context),

              // Settings menu
              _buildSettingsMenu(context),

              // Support menu
              _buildSupportMenu(context),

              verticalSpace(32),

              // Logout button
              _buildLogoutButton(context, ref),

              verticalSpace(16),

              // Version info
              _buildVersionInfo(),

              verticalSpace(25)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSuperAdminMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Admin Panel'),
        verticalSpace(16),
        profileItem(
          'User Management',
          icon: Icons.people_outline,
          onTap: () => context.pushNamed('user-management'),
        ),
        verticalSpace(20),
        profileItem(
          'Role Management',
          icon: Icons.admin_panel_settings_outlined,
          onTap: () => context.pushNamed('role-management'),
        ),
        verticalSpace(12),
        const Divider(color: AppColors.neutral700),
        verticalSpace(12),
      ],
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Management'),
        verticalSpace(16),
        profileItem(
          'Program Management',
          icon: Icons.school_outlined,
          onTap: () => context.pushNamed('program-management'),
        ),
        verticalSpace(20),
        profileItem(
          'Presensi Management',
          icon: Icons.fact_check_outlined,
          onTap: () => context.pushNamed('presensi-management'),
        ),
        verticalSpace(12),
        const Divider(color: AppColors.neutral700),
        verticalSpace(12),
      ],
    );
  }

  Widget _buildCommonMenuItems(BuildContext context) {
    return Column(
      children: [
        profileItem(
          'Update Profil',
          icon: Icons.edit_outlined,
          onTap: () => context.pushNamed('update-profile'),
        ),
        verticalSpace(20),
        profileItem(
          'Ganti Password',
          icon: Icons.lock_outline,
          onTap: () => context.pushNamed('forgot-password'),
        ),
        verticalSpace(12),
        const Divider(color: AppColors.neutral700),
        verticalSpace(12),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Column(
      children: [
        profileItem(
          'Pengaturan Notifikasi',
          icon: Icons.notifications_outlined,
          onTap: () => context.pushNamed('notification-settings'),
        ),
        verticalSpace(20),
        profileItem(
          'Bahasa',
          icon: Icons.language_outlined,
          onTap: () => context.pushNamed('language-settings'),
        ),
        verticalSpace(12),
        const Divider(color: AppColors.neutral700),
        verticalSpace(12),
      ],
    );
  }

  Widget _buildSupportMenu(BuildContext context) {
    return Column(
      children: [
        profileItem(
          'Bantuan',
          icon: Icons.help_outline,
          onTap: () => context.pushNamed('help-center'),
        ),
        verticalSpace(20),
        profileItem(
          'Kebijakan Privasi',
          icon: Icons.privacy_tip_outlined,
          onTap: () => context.pushNamed('privacy-policy'),
        ),
        verticalSpace(20),
        profileItem(
          'Syarat & Ketentuan',
          icon: Icons.description_outlined,
          onTap: () => context.pushNamed('terms-conditions'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await ref.read(userDataProvider.notifier).logout();
        } catch (e) {
          if (context.mounted) {
            context.showErrorSnackBar(e.toString());
          }
        }
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
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Versi 1.0.0',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: AppColors.neutral600,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
    );
  }
}
