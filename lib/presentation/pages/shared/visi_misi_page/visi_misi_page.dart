import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../misc/constants.dart';
import '../../../misc/methods.dart';

class VisiMisiPage extends ConsumerWidget {
  const VisiMisiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('main');
        }
        return false;
      },
      child: Scaffold(
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
              leading: Container(),
              leadingWidth: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('main');
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
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
                    // Title
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 24,
                      right: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visi & Misi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Saung Tahfidz Indonesia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visi Section
                    Text(
                      'Visi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    verticalSpace(16),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Text(
                        'Menjadi lembaga pendidikan Al-Quran yang unggul dalam melahirkan generasi Qurani yang berakhlak mulia dan berwawasan global.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          height: 1.6,
                          color: AppColors.neutral800,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    verticalSpace(32),

                    // Misi Section
                    Text(
                      'Misi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    verticalSpace(16),
                    _buildMissionCard(
                      number: "01",
                      mission:
                          "Menyelenggarakan pendidikan Al-Quran yang sistematis dan berkualitas",
                      icon: Icons.menu_book_rounded,
                    ),
                    verticalSpace(16),
                    _buildMissionCard(
                      number: "02",
                      mission:
                          "Membentuk karakter Islami dan akhlak mulia pada setiap santri",
                      icon: Icons.psychology_rounded,
                    ),
                    verticalSpace(16),
                    _buildMissionCard(
                      number: "03",
                      mission:
                          "Mengembangkan metode pembelajaran Al-Quran yang efektif dan inovatif",
                      icon: Icons.lightbulb_rounded,
                    ),
                    verticalSpace(16),
                    _buildMissionCard(
                      number: "04",
                      mission:
                          "Membangun kerjasama dengan berbagai pihak untuk pengembangan pendidikan Al-Quran",
                      icon: Icons.handshake_rounded,
                    ),
                    verticalSpace(32),

                    // Values Section
                    Text(
                      'Nilai-Nilai Kami',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    verticalSpace(16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildValueCard(
                          title: "Integritas",
                          description: "Menjunjung tinggi kejujuran dan amanah",
                          icon: Icons.verified_user_rounded,
                        ),
                        _buildValueCard(
                          title: "Inovasi",
                          description: "Selalu berinovasi dalam pembelajaran",
                          icon: Icons.lightbulb_outline_rounded,
                        ),
                        _buildValueCard(
                          title: "Kualitas",
                          description:
                              "Mengutamakan kualitas dalam setiap aspek",
                          icon: Icons.star_outline_rounded,
                        ),
                        _buildValueCard(
                          title: "Kolaborasi",
                          description: "Membangun kerjasama yang positif",
                          icon: Icons.people_outline_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({
    required String number,
    required String mission,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                verticalSpace(4),
                Text(
                  mission,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tambahkan ini
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28, // Kurangi ukuran icon
          ),
          verticalSpace(8), // Kurangi spacing
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, // Kurangi ukuran font
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
          verticalSpace(4), // Kurangi spacing
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11, // Kurangi ukuran font
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Batasi jumlah baris
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
