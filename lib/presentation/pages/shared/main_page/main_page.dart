import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sti_app/presentation/pages/beranda_page/beranda_page.dart';
import '../../../extensions/extensions.dart';
import '../../../misc/constants.dart';
import '../../../providers/router/router_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/sti_bottom_nav_bar_widget.dart';
import '../../presensi_page/presensi_page.dart';
import '../profile_page/profile_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int selectedIndex = 0;

  // // Define all screens
  // final List<Widget> _screens = [
  //   const BerandaPage(),
  //   const PresensiPage(),
  //   const Center(child: Text('Progres Page')),
  //   const ProfilePage(),
  // ];

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
        children: _buildScreensForRole(userRole),
      ),
      bottomNavigationBar: STIBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onNavTap,
      ),
    );
  }

  List<Widget> _buildScreensForRole(String role) {
    // Basic screens available for all roles
    final screens = <Widget>[
      const BerandaPage(),
      if (role == 'santri') const PresensiPage(),
      const Center(child: Text('Progres Page')), // Placeholder
      const ProfilePage(),
    ];

    return screens;
  }

  // Helper untuk mengecek apakah role memiliki akses ke screen
  bool _hasAccess(String role, int screenIndex) {
    switch (screenIndex) {
      case 0: // Beranda
        return true;
      case 1: // Presensi
        return role == 'santri';
      case 2: // Progres
        return true;
      case 3: // Profile
        return true;
      default:
        return false;
    }
  }
}
