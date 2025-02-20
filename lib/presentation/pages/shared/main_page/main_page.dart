import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../beranda_page/beranda_page.dart';
import '../../presensi_page/presensi_page.dart';
import '../../progres_page/progres_page.dart';
import '../profile_page/profile_page.dart';
import '../../../extensions/extensions.dart';
import '../../../misc/constants.dart';
import '../../../providers/router/router_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/sti_bottom_nav_bar_widget.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int selectedIndex = 0;

  void onNavTap(int index) {
    final userRole = ref.read(userDataProvider).value?.role;

    if (!_hasAccess(userRole ?? '', index)) {
      context.showErrorSnackBar('Anda tidak memiliki akses ke halaman ini');
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;
    final isAdmin = userRole == 'admin' || userRole == 'superAdmin';

    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Listen untuk state changes
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (previous != null && next is AsyncData && next.value == null) {
          ref.read(routerProvider).goNamed('login');
        } else if (next is AsyncError) {
          context.showSnackBar(next.error.toString());
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: selectedIndex,
        children: _buildScreensForRole(userRole, isAdmin),
      ),
      bottomNavigationBar: STIBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onNavTap,
        role: userRole,
        isAdmin: isAdmin,
      ),
    );
  }

  List<Widget> _buildScreensForRole(String role, bool isAdmin) {
    return [
      const BerandaPage(), // Beranda available for all
      if (!isAdmin) const PresensiPage(), // Presensi only for santri
      const ProgresPage(), // Progres for all with role-based content
      const ProfilePage(), // Profile for all
    ];
  }

  bool _hasAccess(String role, int screenIndex) {
    final isAdmin = role == 'admin' || role == 'superAdmin';

    switch (screenIndex) {
      case 0: // Beranda
        return true; // All roles can access
      case 1: // Presensi
        return !isAdmin; // Only santri can access
      case 2: // Progres
        return true; // All roles with different content
      case 3: // Profile
        return true; // All roles can access
      default:
        return false;
    }
  }
}
