import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../pages/admin/input_presensi/input_presensi_page.dart';
import '../../pages/admin/manage_presensi_page/manage_presensi_page.dart';
import '../../pages/forgot_password_page/forgot_password_page.dart';
import '../../pages/kontak_page/kontak_page.dart';
import '../../pages/login_page/login_page.dart';
import '../../pages/lokasi_page/lokasi_page.dart';
import '../../pages/main_page/main_page.dart';
import '../../pages/onboarding_screen_page/onboarding_screen_page.dart';
import '../../pages/presensi_detail_page/presensi_detail_page.dart';
import '../../pages/presensi_statistic_page/presensi_statistics_page.dart';
import '../../pages/register_page/register_page.dart';
import '../../pages/splash_screen/splash_screen.dart';
import '../../pages/visi_misi_page/visi_misi_page.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
Raw<GoRouter> router(RouterRef ref) => GoRouter(
      routes: [
        GoRoute(
          path: '/main',
          name: 'main',
          builder: (context, state) => const MainPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/splash_screen',
          name: 'splash_screen',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/forgot_password',
          name: 'forgot_password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/visi-misi',
          name: 'visi-misi',
          builder: (context, state) => const VisiMisiPage(),
        ),
        GoRoute(
          path: '/kontak',
          name: 'kontak',
          builder: (context, state) => const KontakPage(),
        ),
        GoRoute(
          path: '/lokasi',
          name: 'lokasi',
          builder: (context, state) => const LokasiPage(),
        ),
        GoRoute(
          path: '/presensi-detail/:programId', // Gunakan parameter path
          name: 'presensi-detail',
          builder: (context, state) => PresensiDetailPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
        ),
        GoRoute(
            path: '/manage-presensi/:programId',
            name: 'manage-presensi',
            builder: (context, state) => ManagePresensiPage(
                  programId: state.pathParameters['programId'] ?? '',
                ),
            routes: [
              GoRoute(
                path: 'input',
                name: 'input-presensi',
                builder: (context, state) => InputPresensiPage(
                  programId: state.pathParameters['programId'] ?? '',
                ),
              ),
            ]),
        GoRoute(
          path: 'statistics',
          name: 'presensi-statistics',
          builder: (context, state) => PresensiStatisticsPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
        ),
      ],
      initialLocation: '/splash_screen',
      debugLogDiagnostics: false,
    );
