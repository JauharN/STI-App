import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sti_app/presentation/providers/router/router_provider.dart';
import 'package:sti_app/presentation/providers/user_data/user_data_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(
      userDataProvider,
      (previous, next) {
        if (previous != null && next is AsyncData && next.value == null) {
          ref.read(routerProvider).goNamed('login');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda STI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selamat datang, ${ref.watch(userDataProvider).when(
                  data: (data) => data.toString(),
                  error: (error, stackTrace) => '',
                  loading: () => 'Loading',
                )}!'),
            // Text('Peran: ${widget.user.role}'),
            ElevatedButton(
              onPressed: () {
                ref.read(userDataProvider.notifier).logout();
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
