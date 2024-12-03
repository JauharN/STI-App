import 'package:firebase_app_check/firebase_app_check.dart';

class FirebaseAppCheckConfig {
  static Future<void> initialize() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  }
}
