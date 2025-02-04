import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/user.dart';
import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/presensi_widget/presensi_program_card_widget.dart';

class PresensiPage extends ConsumerStatefulWidget {
  const PresensiPage({super.key});

  @override
  ConsumerState<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends ConsumerState<PresensiPage> {
  // RBAC Helper
  bool _canManagePresensi(String? role) {
    return role == RoleConstants.admin || role == RoleConstants.superAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, user),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, User? user) {
    final isAdmin = _canManagePresensi(user?.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isAdmin),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgramSection(context, isAdmin, user),
                  if (isAdmin) ...[
                    const Divider(height: 1, color: AppColors.neutral200),
                    _buildQuickActionsSection(context),
                  ],
                  _buildRecentActivitySection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isAdmin) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.25,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/green-pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            _buildAppBarTitle(context, isAdmin),
          ],
        ),
      ),
      actions: _buildAppBarActions(context, isAdmin),
    );
  }

  Widget _buildAppBarTitle(BuildContext context, bool isAdmin) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presensi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAdmin ? 'Kelola Presensi Santri' : 'Riwayat Kehadiran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, bool isAdmin) {
    if (!isAdmin) return [];

    return [
      IconButton(
        onPressed: () => context.pushNamed('input-presensi'),
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
        ),
      ),
      IconButton(
        onPressed: () => context.pushNamed('manage-presensi'),
        icon: const Icon(
          Icons.history,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildProgramSection(BuildContext context, bool isAdmin, User? user) {
    final programs = [
      {'id': 'TAHFIDZ', 'title': 'TAHFIDZ'},
      {'id': 'GMM', 'title': 'GMM'},
      {'id': 'IFIS', 'title': 'IFIS'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          verticalSpace(8),
          Text(
            isAdmin
                ? 'Pilih program untuk mengelola presensi'
                : 'Pilih program untuk melihat presensi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
          ),
          verticalSpace(24),
          ...programs.map((program) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PresensiProgramCard(
                  title: program['title']!,
                  userId: user?.uid ?? '',
                  programId: program['id']!,
                  onTap: () => _navigateToProgram(
                    context,
                    isAdmin,
                    program['id']!,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _navigateToProgram(
      BuildContext context, bool isAdmin, String programId) {
    if (isAdmin) {
      context.pushNamed(
        'manage-presensi',
        pathParameters: {'programId': programId},
      );
    } else {
      context.pushNamed(
        'presensi-detail',
        pathParameters: {'programId': programId},
      );
    }
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          verticalSpace(16),
          _buildQuickActionCard(
            icon: Icons.add_circle_outline,
            title: 'Input Presensi',
            subtitle: 'Input presensi untuk pertemuan baru',
            color: AppColors.primary,
            onTap: () => context.pushNamed(
              'input-presensi',
              pathParameters: {'programId': 'TAHFIDZ'},
            ),
          ),
          verticalSpace(16),
          _buildQuickActionCard(
            icon: Icons.edit_outlined,
            title: 'Kelola Presensi',
            subtitle: 'Edit atau hapus data presensi',
            color: AppColors.secondary,
            onTap: () => context.pushNamed('manage-presensi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    // TODO: Implement recent activity
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktivitas Terkini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          verticalSpace(16),
          // Placeholder untuk recent activity
          Center(
            child: Text(
              'Coming Soon',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.neutral600,
            ),
          ],
        ),
      ),
    );
  }
}
