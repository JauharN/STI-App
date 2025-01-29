import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'config/firebase_app_check.dart';
import 'firebase_options.dart';
import 'presentation/misc/constants.dart';
import 'presentation/providers/program/program_initializer_provider.dart';
import 'presentation/providers/router/router_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // try {
    //   await FirebaseAppCheckConfig.initialize();
    // } catch (e) {
    //   debugPrint('Warning: App Check initialization failed: $e');
    // }

    // Configure Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Initialize provider container
    final container = ProviderContainer();

    // Initialize programs with error handling
    try {
      if (!container.read(programInitializationStateProvider)) {
        await container
            .read(programInitializationStateProvider.notifier)
            .initialize();
      }
    } catch (e) {
      debugPrint('Warning: Program initialization failed: $e');
    }

    runApp(const ProviderScope(
      child: MainApp(),
    ));
  } catch (e, stack) {
    debugPrint('Critical error initializing app: $e\n$stack');
    // Consider showing error UI here
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routeInformationParser: ref.watch(routerProvider).routeInformationParser,
      routeInformationProvider:
          ref.watch(routerProvider).routeInformationProvider,
      routerDelegate: ref.watch(routerProvider).routerDelegate,
    );
  }
}
