import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/news_model.dart';
import '../../pages/admin/presensi/edit_presensi/edit_presensi_page.dart';
import '../../pages/admin/presensi/input_presensi/input_presensi_page.dart';
import '../../pages/admin/presensi/manage_presensi_page/manage_presensi_page.dart';
import '../../pages/admin/user_management/role_management_page.dart';
import '../../pages/admin/user_management/user_management_page.dart';
import '../../pages/news_detail_page/news_detail_page.dart';
import '../../pages/presensi_page/presensi_page.dart';
import '../../pages/progres_page/admin/edit_progres_page.dart';
import '../../pages/progres_page/admin/input_progres_page.dart';
import '../../pages/progres_page/progres_detail_page.dart';
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
          path: '/news-detail',
          name: 'news-detail',
          builder: (context, state) {
            final news = state.extra as News;
            return NewsDetailPage(news: news);
          },
        ),
        // Route untuk presensi
        GoRoute(
          path: '/presensi',
          name: 'presensi',
          builder: (context, state) => const PresensiPage(),
          routes: [
            GoRoute(
              path: 'detail/:programId',
              name: 'presensi-detail',
              builder: (context, state) => PresensiDetailPage(
                programId: state.pathParameters['programId'] ?? '',
              ),
            ),
            GoRoute(
              path: 'manage/:programId',
              name: 'manage-presensi',
              builder: (context, state) {
                final userRole = ref.read(userDataProvider).value?.role;
                // Check role dengan string
                if (userRole != 'admin' && userRole != 'superAdmin') {
                  return const UnauthorizedPage();
                }
                return ManagePresensiPage(
                  programId: state.pathParameters['programId'] ?? '',
                );
              },
              routes: [
                GoRoute(
                  path: 'input',
                  name: 'input-presensi',
                  builder: (context, state) {
                    final userRole = ref.read(userDataProvider).value?.role;
                    // Check role dengan string
                    if (userRole != 'admin' && userRole != 'superAdmin') {
                      return const UnauthorizedPage();
                    }
                    return InputPresensiPage(
                      programId: state.pathParameters['programId'] ?? '',
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/:presensiId',
                  name: 'edit-presensi',
                  builder: (context, state) {
                    final userRole = ref.read(userDataProvider).value?.role;
                    if (userRole != 'admin' && userRole != 'superAdmin') {
                      return const UnauthorizedPage();
                    }
                    return EditPresensiPage(
                      programId: state.pathParameters['programId'] ?? '',
                      pertemuanId: state.pathParameters['presensiId'] ?? '',
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'statistics/:programId',
              name: 'presensi-statistics',
              builder: (context, state) => PresensiStatisticsPage(
                programId: state.pathParameters['programId'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/role-management',
          name: 'role-management',
          builder: (context, state) {
            final userRole = ref.read(userDataProvider).value?.role;
            // Check superAdmin role dengan string
            if (userRole != 'superAdmin') {
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
            // Check superAdmin role dengan string
            if (userRole != 'superAdmin') {
              return const UnauthorizedPage();
            }
            return const UserManagementPage();
          },
        ),
        GoRoute(
          path: '/progres-detail/:id',
          name: 'progres-detail',
          builder: (context, state) => ProgresDetailPage(
            id: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/input-progres',
          name: 'input-progres',
          builder: (context, state) {
            final userRole = ref.read(userDataProvider).value?.role;
            if (userRole != 'admin' && userRole != 'superAdmin') {
              return const UnauthorizedPage();
            }
            return const InputProgresPage();
          },
        ),
        GoRoute(
          path: '/edit-progres/:id',
          name: 'edit-progres',
          builder: (context, state) {
            final userRole = ref.read(userDataProvider).value?.role;
            if (userRole != 'admin' && userRole != 'superAdmin') {
              return const UnauthorizedPage();
            }
            return EditProgresPage(
              id: state.pathParameters['id'] ?? '',
            );
          },
        ),
      ],
      initialLocation: '/splash_screen',
      debugLogDiagnostics: false,
    );
