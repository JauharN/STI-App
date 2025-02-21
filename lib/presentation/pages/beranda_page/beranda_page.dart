import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/program.dart';
import '../../misc/constants.dart';
import '../../providers/news/news_provider.dart';
import '../../providers/program/available_programs_provider.dart';
import '../../providers/user_data/user_data_provider.dart';

class BerandaPage extends ConsumerWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider).valueOrNull;
    final isAdmin = user?.role == 'admin' || user?.role == 'superAdmin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.2,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leadingWidth: 0,
            leading: Container(),
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
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 0,
                    right: 0,
                    child: _buildHeader(ref),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Notification handler
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8F8DE),
              child: Column(
                children: [
                  _buildMenuSection(context, isAdmin),
                  _buildProgramSection(context, ref, isAdmin),
                  if (!isAdmin) _buildRecentNews(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final user = ref.watch(userDataProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalamu\'alaikum',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.name ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: _buildMenuItems(context, isAdmin),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, bool isAdmin) {
    final menuItems = [
      (
        'Visi & Misi',
        Icons.description_outlined,
        AppColors.primary,
        'visi-misi'
      ),
      (
        isAdmin ? 'Kelola Program' : 'Program',
        Icons.school_rounded,
        AppColors.secondary,
        isAdmin ? 'manage-program' : 'program'
      ),
      ('Jadwal', Icons.calendar_today_rounded, AppColors.primary, 'jadwal'),
      ('Presensi', Icons.fact_check_rounded, AppColors.secondary, 'presensi'),
      ('Progres', Icons.trending_up_rounded, AppColors.primary, 'progres'),
      (
        'Pengumuman',
        Icons.campaign_outlined,
        AppColors.secondary,
        'pengumuman'
      ),
      ('Kontak', Icons.contacts_outlined, AppColors.primary, 'kontak'),
      ('Lokasi', Icons.location_on_outlined, AppColors.secondary, 'lokasi'),
    ];

    return menuItems
        .map(
          (item) => MenuCard(
            title: item.$1,
            icon: item.$2,
            color: item.$3,
            onTap: () => context.pushNamed(item.$4),
          ),
        )
        .toList();
  }

  Widget _buildProgramSection(
      BuildContext context, WidgetRef ref, bool isAdmin) {
    final programsAsync = ref.watch(availableProgramsStateProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Mencegah overflow teks di dalam Row
                child: Text(
                  isAdmin ? 'Program Management' : 'Program Terdaftar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isAdmin)
                TextButton.icon(
                  onPressed: () => context.pushNamed('manage-program'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tambah Program'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          programsAsync.when(
            data: (programs) {
              if (programs.isEmpty) {
                return _buildEmptyProgramState(context, isAdmin);
              }
              return SizedBox(
                width: double
                    .infinity, // Membatasi ListView agar tidak lebih lebar dari parent
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: programs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildProgramCard(context, programs[index], isAdmin),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error: ${error.toString()}',
                style: GoogleFonts.plusJakartaSans(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(
    BuildContext context,
    Program program,
    bool isAdmin,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.pushNamed(
          isAdmin ? 'manage-program-detail' : 'program-detail',
          pathParameters: {'programId': program.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          program.deskripsi,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.neutral600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Teacher Section
              if (program.pengajarNames.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Pengajar:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: program.pengajarNames
                      .map((name) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ] else ...[
                Text(
                  'Belum ada pengajar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.neutral600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Schedule & Location
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Jadwal: ${program.jadwal.join(", ")}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              if (program.lokasi != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      program.lokasi!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyProgramState(BuildContext context, bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              isAdmin ? 'Belum ada program' : 'Belum terdaftar di program',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.neutral600,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.pushNamed('manage-program'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah Program Baru'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNews(BuildContext context, WidgetRef ref) {
    final newsList = ref.watch(newsListProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Berita Terbaru',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: newsList.map((news) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: news.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            news.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.article,
                          size: 50,
                          color: AppColors.neutral600,
                        ),
                  title: Text(
                    news.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  subtitle: Text(
                    news.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    context.pushNamed(
                      'news-detail',
                      extra: news,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral800,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
