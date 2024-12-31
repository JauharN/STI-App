import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object? error;
  final String location;

  const ErrorPage({
    required this.error,
    required this.location,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Text('Error: ${error.toString()}'),
      );
}
