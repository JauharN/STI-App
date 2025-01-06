import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user.dart';
import '../../pages/admin/input_presensi/input_presensi_page.dart';
import '../../pages/admin/manage_presensi_page/manage_presensi_page.dart';
import '../../pages/admin/user_management/role_management_page.dart';
import '../../pages/admin/user_management/user_management_page.dart';
import '../../pages/shared/forgot_password_page/forgot_password_page.dart';
import '../../pages/shared/kontak_page/kontak_page.dart';
import '../../pages/shared/login_page/login_page.dart';
import '../../pages/shared/lokasi_page/lokasi_page.dart';
import '../../pages/shared/main_page/main_page.dart';
import '../../pages/shared/onboarding_screen_page/onboarding_screen_page.dart';
import '../../pages/presensi_detail_page/presensi_detail_page.dart';
import '../../pages/presensi_statistics_page/presensi_statistics_page.dart';
import '../../pages/shared/register_page/register_page.dart';
import '../../pages/shared/shared_page/unauthorized_page.dart';
import '../../pages/shared/splash_screen_page/splash_screen_page.dart';
import '../../pages/shared/visi_misi_page/visi_misi_page.dart';
import '../user_data/user_data_provider.dart';

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
          ],
        ),
        GoRoute(
          path: 'statistics',
          name: 'presensi-statistics',
          builder: (context, state) => PresensiStatisticsPage(
            programId: state.pathParameters['programId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/role-management',
          name: 'role-management',
          builder: (context, state) {
            final userRole = ref.read(userDataProvider).value?.role;
            if (userRole != UserRole.superAdmin) {
              return const UnauthorizedPage();
            }
            return const RoleManagementPage();
          },
        ),
        GoRoute(
          path: '/user-management',
          name: 'user-management',
          builder: (context, state) {
            final userRole = ref.read(userDataProvider).value?.role;
            if (userRole != UserRole.superAdmin) {
              return const UnauthorizedPage();
            }
            return const UserManagementPage();
          },
        ),
      ],
      initialLocation: '/splash_screen',
      debugLogDiagnostics: false,
    );
