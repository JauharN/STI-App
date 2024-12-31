import 'package:flutter/material.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  final Stream<dynamic> stream;

  GoRouterRefreshStream(this.stream) {
    stream.listen((dynamic _) => notifyListeners());
  }
}
