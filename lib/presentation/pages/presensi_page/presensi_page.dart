import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/presensi/presensi_summary.dart';
import '../../../domain/entities/user.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/presensi/recent_presensi_activities_provider.dart';
import '../../providers/program/available_programs_provider.dart';
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

  bool _canInputPresensi(String? role) {
    return _canManagePresensi(role);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, user),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: ${error.toString()}')),
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
        onPressed: () => context.pushNamed('input-presensi',
            pathParameters: {'programId': 'TAHFIDZ'}),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
      ),
      IconButton(
        onPressed: () => context.pushNamed(
          'manage-presensi',
          pathParameters: {'programId': 'TAHFIDZ'},
        ),
        icon: const Icon(Icons.history, color: Colors.white),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildProgramSection(BuildContext context, bool isAdmin, User? user) {
    final programsAsync = ref.watch(availableProgramsStateProvider);

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
          programsAsync.when(
            data: (programs) {
              if (programs.isEmpty) {
                return _buildEmptyState(isAdmin
                    ? 'Belum ada program yang dikelola'
                    : 'Belum terdaftar di program');
              }
              return Column(
                children: programs.map((program) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PresensiProgramCard(
                      title: program.nama,
                      userId: user?.uid ?? '',
                      programId: program.id,
                      onTap: () => _navigateToProgram(
                        context,
                        isAdmin,
                        program.id,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error: $error',
                style: GoogleFonts.plusJakartaSans(color: AppColors.error),
              ),
            ),
          ),
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
            onTap: () => context.pushNamed(
              'manage-presensi',
              pathParameters: {'programId': 'TAHFIDZ'},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Terkini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              if (_canManagePresensi(userRole))
                TextButton(
                  onPressed: () => context.pushNamed('presensi-statistics'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          verticalSpace(16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final availableProgramsAsync = ref.watch(availableProgramsStateProvider);

    return availableProgramsAsync.when(
      data: (programs) {
        if (programs.isEmpty) {
          return _buildEmptyState('Belum ada aktivitas presensi');
        }

        // Use first program as default
        return _buildActivityList(programs.first.id);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error',
            style: GoogleFonts.plusJakartaSans(color: AppColors.error)),
      ),
    );
  }

  Widget _buildActivityList(String programId) {
    final activitiesAsync =
        ref.watch(recentPresensiActivitiesControllerProvider(programId));

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return _buildEmptyState('Belum ada aktivitas presensi');
        }

        final statistics = ref
            .read(
                recentPresensiActivitiesControllerProvider(programId).notifier)
            .getActivityStatistics(activities);

        return Column(
          children: [
            _buildStatisticsCard(statistics),
            verticalSpace(16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildActivityItem(activities[index]),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error',
            style: GoogleFonts.plusJakartaSans(color: AppColors.error)),
      ),
    );
  }

  Widget _buildActivityItem(PresensiPertemuan activity) {
    return InkWell(
      onTap: () => context.pushNamed(
        'presensi-detail',
        pathParameters: {'programId': activity.programId},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.fact_check_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertemuan ke-${activity.pertemuanKe}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hadir: ${activity.summary.hadir} | Tidak Hadir: ${activity.summary.totalSantri - activity.summary.hadir}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatDate(activity.tanggal),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activity.summary.persentaseKehadiran.toStringAsFixed(1)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, int> statistics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Hadir',
            '${statistics['totalHadir']}',
            Icons.check_circle_outline,
          ),
          _buildStatItem(
            'Total Santri',
            '${statistics['totalSantri']}',
            Icons.people_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
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
