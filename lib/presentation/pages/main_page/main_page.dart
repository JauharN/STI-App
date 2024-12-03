// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sti_app/presentation/pages/beranda_page/beranda_page.dart';

// import '../../extensions/extensions.dart';
// import '../../misc/constants.dart';
// import '../../providers/router/router_provider.dart';
// import '../../providers/user_data/user_data_provider.dart';
// import '../../widgets/sti_bottom_nav_bar_widget.dart';
// import '../profile_page/profile_page.dart';

// class MainPage extends ConsumerStatefulWidget {
//   const MainPage({super.key});

//   @override
//   ConsumerState<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends ConsumerState<MainPage> {
//   late PageController pageController;
//   int selectedPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController();
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }

//   void onNavTap(int index) {
//     setState(() {
//       selectedPage = index;
//     });
//     pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ref.listen(
//       userDataProvider,
//       (previous, next) {
//         if (previous != null && next is AsyncData && next.value == null) {
//           ref.read(routerProvider).goNamed('login');
//         } else if (next is AsyncError) {
//           context.showSnackBar(next.error.toString());
//         }
//       },
//     );

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: PageView(
//         controller: pageController,
//         onPageChanged: (value) => setState(() {
//           selectedPage = value;
//         }),
//         children: const [
//           BerandaPage(),
//           // PresensiPage(),
//           Center(child: Text('Progres page')),
//           ProfilePage(),
//         ],
//       ),
//       bottomNavigationBar: STIBottomNavBar(
//         selectedIndex: selectedPage,
//         onTap: onNavTap,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sti_app/presentation/pages/beranda_page/beranda_page.dart';
import '../../extensions/extensions.dart';
import '../../misc/constants.dart';
import '../../providers/router/router_provider.dart';
import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/sti_bottom_nav_bar_widget.dart';
import '../presensi_page/presensi_page.dart';
import '../profile_page/profile_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int selectedIndex = 0;

  // Define all screens
  final List<Widget> _screens = [
    const BerandaPage(),
    const PresensiPage(),
    const Center(child: Text('Progres Page')),
    const ProfilePage(),
  ];

  void onNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        children: _screens,
      ),
      bottomNavigationBar: STIBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onNavTap,
      ),
    );
  }
}
