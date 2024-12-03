import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/firebase_app_check.dart';
import 'firebase_options.dart';
import 'presentation/misc/constants.dart';
import 'presentation/providers/program/program_initializer_provider.dart';
import 'presentation/providers/router/router_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize App Check
    await FirebaseAppCheckConfig.initialize();

    // Set Firestore settings with persistence enabled
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    final container = ProviderContainer();

    // Initialize programs if needed
    if (!container.read(programInitializationStateProvider)) {
      await container
          .read(programInitializationStateProvider.notifier)
          .initialize();
    }

    runApp(const ProviderScope(
      child: MainApp(),
    ));
  } catch (e, stack) {
    debugPrint('Error initializing app: $e\n$stack');
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
