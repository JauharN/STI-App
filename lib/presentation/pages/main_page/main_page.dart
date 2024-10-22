import 'package:flutter/material.dart';

import '../../../domain/entities/user.dart';

class MainPage extends StatelessWidget {
  final User user;
  const MainPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda STI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selamat datang, ${user.name}!'),
            Text('Peran: ${user.role}'),
            // Tambahkan widget lain sesuai kebutuhan STI
          ],
        ),
      ),
    );
  }
}
