// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../providers/user_data/user_data_provider.dart';

// class ScaffoldWithNavBar extends ConsumerWidget {
//   final Widget child;

//   const ScaffoldWithNavBar({
//     required this.child,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       body: child,
//       bottomNavigationBar: Consumer(
//         builder: (context, ref, _) {
//           final userRole = ref.watch(userDataProvider).value?.role;
//           final currentRoute = GoRouterState.of(context).uri.toString();
//           return NavigationBar(
//             selectedIndex: _calculateSelectedIndex(currentRoute),
//             onDestinationSelected: (index) =>
//                 _onItemTapped(index, context, userRole),
//             destinations: _buildDestinations(userRole),
//           );
//         },
//       ),
//     );
//   }

//   int _calculateSelectedIndex(String route) {
//     if (route.startsWith('/main')) return 0;
//     if (route.startsWith('/presensi')) return 1;
//     if (route.startsWith('/program') || route.startsWith('/manage-program'))
//       return 2;
//     if (route.startsWith('/profile')) return 3;
//     return 0;
//   }

//   void _onItemTapped(int index, BuildContext context, String? role) {
//     switch (index) {
//       case 0:
//         context.go('/main');
//         break;
//       case 1:
//         if (_canAccessPresensi(role)) {
//           context.go('/presensi');
//         }
//         break;
//       case 2:
//         if (_canAccessProgram(role)) {
//           role == 'santri'
//               ? context.go('/program')
//               : context.go('/manage-program');
//         }
//         break;
//       case 3:
//         context.go('/profile');
//         break;
//     }
//   }

//   bool _canAccessPresensi(String? role) =>
//       role == 'admin' || role == 'superAdmin' || role == 'santri';

//   bool _canAccessProgram(String? role) =>
//       role == 'admin' || role == 'superAdmin' || role == 'santri';

//   List<NavigationDestination> _buildDestinations(String? role) {
//     return [
//       const NavigationDestination(
//         icon: Icon(Icons.home_outlined),
//         selectedIcon: Icon(Icons.home),
//         label: 'Beranda',
//       ),
//       const NavigationDestination(
//         icon: Icon(Icons.calendar_today_outlined),
//         selectedIcon: Icon(Icons.calendar_today),
//         label: 'Presensi',
//       ),
//       NavigationDestination(
//         icon: const Icon(Icons.book_outlined),
//         selectedIcon: const Icon(Icons.book),
//         label: role == 'santri' ? 'Program' : 'Manage',
//       ),
//       const NavigationDestination(
//         icon: Icon(Icons.person_outline),
//         selectedIcon: Icon(Icons.person),
//         label: 'Profile',
//       ),
//     ];
//   }
// }

// Widget deprecated tak digunakan...