import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class FirebaseAppCheckConfig {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static Future<void> initialize() async {
    int retryCount = 0;
    bool initialized = false;

    while (!initialized && retryCount < _maxRetries) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
        );

        // Monitor token status
        FirebaseAppCheck.instance.onTokenChange.listen(
          (String? token) {
            if (token == null) {
              _retryTokenRefresh();
            } else {
              debugPrint('App Check token refreshed successfully');
            }
          },
          onError: (error) {
            debugPrint('App Check token error: $error');
            _retryTokenRefresh();
          },
        );

        initialized = true;
        debugPrint('Firebase App Check initialized successfully');
      } catch (e) {
        retryCount++;
        debugPrint(
            'Firebase App Check initialization attempt $retryCount failed: $e');

        if (retryCount < _maxRetries) {
          await Future.delayed(_retryDelay);
        } else {
          debugPrint(
              'Firebase App Check initialization failed after $_maxRetries attempts');
          rethrow;
        }
      }
    }
  }

  static Future<void> _retryTokenRefresh() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await FirebaseAppCheck.instance.getToken();
        debugPrint('App Check token refresh successful');
        return;
      } catch (e) {
        retryCount++;
        debugPrint('Token refresh attempt $retryCount failed: $e');
        await Future.delayed(_retryDelay);
      }
    }
    debugPrint('Token refresh failed after $_maxRetries attempts');
  }
}
