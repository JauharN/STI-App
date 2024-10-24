import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:sti_app/data/dummies/dummy_authentication.dart';
// import 'package:sti_app/data/dummies/dummy_user_repository.dart';
import 'package:sti_app/presentation/pages/main_page/main_page.dart';
import 'package:sti_app/presentation/providers/usecases/login_provider.dart';

import '../../../domain/usecase/authentication/login/login.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Login login = ref.watch(loginProvider);

            login(LoginParams(
                    email: 'generalkanki26@gmail.com', password: 'abc123'))
                .then((result) {
              if (result.isSuccess) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MainPage(user: result.resultValue!),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.errorMessage!),
                  ),
                );
              }
            });
          },
          child: const Text('Login Tes'),
        ),
      ),
    );
  }
}
