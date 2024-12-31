import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user.dart';
import '../providers/user_data/user_data_provider.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final userRole = ref.watch(userDataProvider).value?.role;
          final currentRoute = GoRouterState.of(context).uri.toString();

          return NavigationBar(
            selectedIndex: _calculateSelectedIndex(currentRoute),
            onDestinationSelected: (index) =>
                _onItemTapped(index, context, userRole),
            destinations: _buildDestinations(userRole),
          );
        },
      ),
    );
  }

  int _calculateSelectedIndex(String route) {
    if (route.startsWith('/main')) return 0;
    if (route.startsWith('/presensi')) return 1;
    if (route.startsWith('/program')) return 2;
    if (route.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, UserRole? role) {
    switch (index) {
      case 0:
        context.go('/main');
        break;
      case 1:
        context.go('/presensi');
        break;
      case 2:
        if (role == UserRole.santri) {
          context.go('/program');
        } else {
          context.go('/manage-program');
        }
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  List<NavigationDestination> _buildDestinations(UserRole? role) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: 'Presensi',
      ),
      NavigationDestination(
        icon: const Icon(Icons.book_outlined),
        selectedIcon: const Icon(Icons.book),
        label: role == UserRole.santri ? 'Program' : 'Manage',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }
}
