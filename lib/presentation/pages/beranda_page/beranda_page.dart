// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../misc/constants.dart';
// import '../../providers/user_data/user_data_provider.dart';

// class BerandaPage extends ConsumerWidget {
//   const BerandaPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Stack(
//         children: [
//           Container(
//             color: const Color(0xFFF8F8DE),
//           ),

//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.43,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/green-pattern.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),

//           // Content
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header content
//                   _buildHeader(ref),
//                   _buildMenuSection(context),
//                   _buildRecentNews(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Assalamu\'alaikum',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 ref.watch(userDataProvider).valueOrNull?.name ?? '',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {
//               // Handle notification
//             },
//             icon: const Icon(
//               Icons.notifications_none_rounded,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuSection(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Menu',
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.neutral900,
//             ),
//           ),
//           const SizedBox(height: 16),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 8,
//                 childAspectRatio: 0.85,
//                 children: _buildMenuItems(context),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildMenuItems(BuildContext context) {
//     final menuItems = [
//       (
//         'Visi & Misi',
//         Icons.description_outlined,
//         AppColors.primary,
//         'visi-misi'
//       ),
//       ('Program', Icons.school_rounded, AppColors.secondary, 'program'),
//       ('Jadwal', Icons.calendar_today_rounded, AppColors.primary, 'jadwal'),
//       ('Presensi', Icons.fact_check_rounded, AppColors.secondary, 'presensi'),
//       ('Progres', Icons.trending_up_rounded, AppColors.primary, 'progres'),
//       (
//         'Pengumuman',
//         Icons.campaign_outlined,
//         AppColors.secondary,
//         'pengumuman'
//       ),
//       ('Kontak', Icons.contacts_outlined, AppColors.primary, 'kontak'),
//       ('Lokasi', Icons.location_on_outlined, AppColors.secondary, 'lokasi'),
//     ];

//     return menuItems
//         .map(
//           (item) => MenuCard(
//             title: item.$1,
//             icon: item.$2,
//             color: item.$3,
//             onTap: () => context.pushNamed(item.$4),
//           ),
//         )
//         .toList();
//   }

//   Widget _buildRecentNews() {
//     // Placeholder untuk news section
//     return const SizedBox.shrink();
//   }
// }

// class MenuCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;
//   final Color color;

//   const MenuCard({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.onTap,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: AppColors.neutral800,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../misc/constants.dart';
import '../../providers/user_data/user_data_provider.dart';

class BerandaPage extends ConsumerWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            leadingWidth: 0, // Remove default leading space
            leading: Container(),
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
                  // Gradient overlay for better text visibility
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
                    top: MediaQuery.of(context).padding.top +
                        16, // Account for status bar
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
                  // Handle notification
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8F8DE),
              child: Column(
                children: [
                  _buildMenuSection(context),
                  _buildRecentNews(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
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
            ref.watch(userDataProvider).valueOrNull?.name ?? '',
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

  Widget _buildMenuSection(BuildContext context) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: _buildMenuItems(context),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      (
        'Visi & Misi',
        Icons.description_outlined,
        AppColors.primary,
        'visi-misi'
      ),
      ('Program', Icons.school_rounded, AppColors.secondary, 'program'),
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

  Widget _buildRecentNews() {
    // Placeholder untuk news section
    // Tambahkan konten news di sini
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
          // Add news items here
        ],
      ),
    );
  }
}

// MenuCard widget remains the same
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
