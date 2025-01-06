import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../misc/constants.dart';
import '../../misc/methods.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/presensi_widget/presensi_program_card.dart';

class PresensiPage extends ConsumerStatefulWidget {
  const PresensiPage({super.key});

  @override
  ConsumerState<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends ConsumerState<PresensiPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background pattern
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/green-pattern.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay
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
                  // Title Section
                  Positioned(
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
                          // User name or role specific text
                          Text(
                            isAdmin
                                ? 'Kelola Presensi Santri'
                                : 'Riwayat Kehadiran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons for admin
            actions: [
              if (isAdmin) ...[
                IconButton(
                  onPressed: () {
                    // Navigate to input presensi page
                    context.pushNamed('input-presensi');
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Navigate to presensi history/management
                    context.pushNamed('manage-presensi');
                  },
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program Section
                  Padding(
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
                        // Program Cards
                        PresensiProgramCard(
                          title: 'TAHFIDZ',
                          userId: user?.uid ?? '',
                          programId: 'TAHFIDZ',
                          onTap: () {
                            if (isAdmin) {
                              // Untuk admin ke manage presensi
                              context.pushNamed('manage-presensi',
                                  pathParameters: {'programId': 'TAHFIDZ'});
                            } else {
                              // Untuk santri ke detail presensi
                              context.pushNamed('presensi-detail',
                                  pathParameters: {'programId': 'TAHFIDZ'});
                            }
                          },
                        ),
                        verticalSpace(16),
                        PresensiProgramCard(
                          title: 'GMM',
                          userId: user?.uid ?? '',
                          programId: 'GMM',
                          onTap: () {
                            if (isAdmin) {
                              context.pushNamed('manage-presensi',
                                  pathParameters: {'programId': 'GMM'});
                            } else {
                              context.pushNamed('presensi-detail',
                                  pathParameters: {'programId': 'GMM'});
                            }
                          },
                        ),
                        verticalSpace(16),
                        PresensiProgramCard(
                          title: 'IFIS',
                          userId: user?.uid ?? '',
                          programId: 'IFIS',
                          onTap: () {
                            if (isAdmin) {
                              context.pushNamed('manage-presensi',
                                  pathParameters: {'programId': 'IFIS'});
                            } else {
                              context.pushNamed('presensi-detail',
                                  pathParameters: {'programId': 'IFIS'});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Admin Quick Actions Section
                  if (isAdmin) ...[
                    const Divider(
                      height: 1,
                      color: AppColors.neutral200,
                    ),
                    Padding(
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
                          // Input Presensi Card
                          _buildQuickActionCard(
                            icon: Icons.add_circle_outline,
                            title: 'Input Presensi',
                            subtitle: 'Input presensi untuk pertemuan baru',
                            color: AppColors.primary,
                            onTap: () {
                              // Gunakan programId yang sudah ada
                              context.pushNamed(
                                'input-presensi',
                                pathParameters: {'programId': 'TAHFIDZ'},
                              );
                            },
                          ),
                          verticalSpace(16),
                          // Manage Presensi Card
                          _buildQuickActionCard(
                            icon: Icons.edit_outlined,
                            title: 'Kelola Presensi',
                            subtitle: 'Edit atau hapus data presensi',
                            color: AppColors.secondary,
                            onTap: () => context.pushNamed('manage-presensi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Recent Activity Section - For both admin and santri
                  Padding(
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
                        // Recent activity items would go here
                        // This could be a list of recent presensi entries
                        // We'll implement this in the next iteration
                      ],
                    ),
                  ),
                ],
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
      child: Container(
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
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
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
