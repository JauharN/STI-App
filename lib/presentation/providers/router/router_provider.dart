import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/user.dart';
import '../../pages/admin/input_presensi/input_presensi_page.dart';
import '../../pages/admin/manage_presensi_page/manage_presensi_page.dart';
import '../../pages/admin/user_management/role_management_page.dart';
import '../../pages/admin/user_management/user_management_page.dart';
import '../../pages/forgot_password_page/forgot_password_page.dart';
import '../../pages/kontak_page/kontak_page.dart';
import '../../pages/login_page/login_page.dart';
import '../../pages/lokasi_page/lokasi_page.dart';
import '../../pages/main_page/main_page.dart';
import '../../pages/onboarding_screen_page/onboarding_screen_page.dart';
import '../../pages/presensi_detail_page/presensi_detail_page.dart';
import '../../pages/presensi_statistic_page/presensi_statistics_page.dart';
import '../../pages/register_page/register_page.dart';
import '../../pages/shared_page/error_page.dart';
import '../../pages/shared_page/unauthorized_page.dart';
import '../../pages/splash_screen/splash_screen.dart';
import '../../pages/visi_misi_page/visi_misi_page.dart';
import '../../widgets/scaffold_with_nav_bar_widget.dart';
import '../user_data/user_data_provider.dart';
import 'go_router_refresh_stream.dart';

part 'router_provider.g.dart';

// @Riverpod(keepAlive: true)
// Raw<GoRouter> router(RouterRef ref) => GoRouter(
//       routes: [
//         GoRoute(
//           path: '/main',
//           name: 'main',
//           builder: (context, state) => const MainPage(),
//         ),
//         GoRoute(
//           path: '/login',
//           name: 'login',
//           builder: (context, state) => const LoginPage(),
//         ),
//         GoRoute(
//           path: '/splash_screen',
//           name: 'splash_screen',
//           builder: (context, state) => const SplashScreen(),
//         ),
//         GoRoute(
//           path: '/onboarding',
//           name: 'onboarding',
//           builder: (context, state) => const OnboardingScreen(),
//         ),
//         GoRoute(
//           path: '/forgot_password',
//           name: 'forgot_password',
//           builder: (context, state) => const ForgotPasswordPage(),
//         ),
//         GoRoute(
//           path: '/register',
//           name: 'register',
//           builder: (context, state) => const RegisterPage(),
//         ),
//         GoRoute(
//           path: '/visi-misi',
//           name: 'visi-misi',
//           builder: (context, state) => const VisiMisiPage(),
//         ),
//         GoRoute(
//           path: '/kontak',
//           name: 'kontak',
//           builder: (context, state) => const KontakPage(),
//         ),
//         GoRoute(
//           path: '/lokasi',
//           name: 'lokasi',
//           builder: (context, state) => const LokasiPage(),
//         ),
//         GoRoute(
//           path: '/presensi-detail/:programId', // Gunakan parameter path
//           name: 'presensi-detail',
//           builder: (context, state) => PresensiDetailPage(
//             programId: state.pathParameters['programId'] ?? '',
//           ),
//         ),
//         GoRoute(
//             path: '/manage-presensi/:programId',
//             name: 'manage-presensi',
//             builder: (context, state) => ManagePresensiPage(
//                   programId: state.pathParameters['programId'] ?? '',
//                 ),
//             routes: [
//               GoRoute(
//                 path: 'input',
//                 name: 'input-presensi',
//                 builder: (context, state) => InputPresensiPage(
//                   programId: state.pathParameters['programId'] ?? '',
//                 ),
//               ),
//             ]),
//         GoRoute(
//           path: 'statistics',
//           name: 'presensi-statistics',
//           builder: (context, state) => PresensiStatisticsPage(
//             programId: state.pathParameters['programId'] ?? '',
//           ),
//         ),
//       ],
//       initialLocation: '/splash_screen',
//       debugLogDiagnostics: false,
//     );

bool _canAccess(UserRole? userRole, Set<UserRole> allowedRoles) {
  if (userRole == null) return false;
  return allowedRoles.contains(userRole);
}

@Riverpod(keepAlive: true)
Raw<GoRouter> router(RouterRef ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  // Helper untuk redirect logic
  String? handleRedirect(String location, User? user) {
    final isAuth = user != null;
    final isPublicRoute = location == '/login' ||
        location == '/register' ||
        location == '/splash_screen' ||
        location == '/onboarding' ||
        location == '/forgot_password';

    if (!isAuth && !isPublicRoute) return '/login';
    if (isAuth && isPublicRoute) return '/main';

    return null;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash_screen',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(userDataProvider.notifier).userStateStream(),
    ),
    redirect: (context, state) {
      final user = ref.read(userDataProvider).value;
      return handleRedirect(state.uri.toString(), user);
    },
    errorBuilder: (context, state) => ErrorPage(
      error: state.error,
      location: state.uri.toString(),
    ),
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          // Group routes by feature
          _publicRoutes(),
          _authenticatedRoutes(ref),
          _presensiRoutes(ref),
          _adminRoutes(ref),
          _superAdminRoutes(ref),
        ],
      ),
    ],
  );
}

// Separate route groups
RouteBase _publicRoutes() => GoRoute(
      path: '/splash_screen',
      name: 'splash_screen',
      builder: (_, __) => const SplashScreen(),
      routes: [
        GoRoute(
          path: 'login',
          name: 'login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: 'register',
          name: 'register',
          builder: (_, __) => const RegisterPage(),
        ),
        GoRoute(
          path: 'forgot_password',
          name: 'forgot_password',
          builder: (_, __) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: 'onboarding',
          name: 'onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
      ],
    );

RouteBase _authenticatedRoutes(RouterRef ref) => ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/main',
          name: 'main',
          builder: (_, __) => const MainPage(),
        ),
        GoRoute(
          path: '/visi-misi',
          name: 'visi-misi',
          builder: (_, __) => const VisiMisiPage(),
        ),
        GoRoute(
          path: '/kontak',
          name: 'kontak',
          builder: (_, __) => const KontakPage(),
        ),
        GoRoute(
          path: '/lokasi',
          name: 'lokasi',
          builder: (_, __) => const LokasiPage(),
        ),
      ],
    );

RouteBase _adminRoutes(RouterRef ref) => ShellRoute(
      builder: (context, state, child) {
        final userRole = ref.read(userDataProvider).value?.role;
        if (!_canAccess(userRole, {UserRole.admin, UserRole.superAdmin})) {
          return const UnauthorizedPage();
        }
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/manage-presensi/:programId',
          name: 'manage-presensi',
          builder: (_, state) => ManagePresensiPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
          routes: [
            GoRoute(
              path: 'input',
              name: 'input-presensi',
              builder: (_, state) => InputPresensiPage(
                programId: state.pathParameters['programId'] ?? '',
              ),
            ),
          ],
        ),
      ],
    );

RouteBase _superAdminRoutes(RouterRef ref) => ShellRoute(
      builder: (context, state, child) {
        final userRole = ref.read(userDataProvider).value?.role;
        if (!_canAccess(userRole, {UserRole.superAdmin})) {
          return const UnauthorizedPage();
        }
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/role-management',
          name: 'role-management',
          builder: (_, __) => const RoleManagementPage(),
        ),
        GoRoute(
          path: '/user-management',
          name: 'user-management',
          builder: (_, __) => const UserManagementPage(),
        ),
      ],
    );

RouteBase _presensiRoutes(RouterRef ref) => ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/presensi-detail/:programId',
          name: 'presensi-detail',
          builder: (_, state) => PresensiDetailPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
        ),
        GoRoute(
          path: 'statistics',
          name: 'presensi-statistics',
          builder: (_, state) => PresensiStatisticsPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
        ),
      ],
    );
