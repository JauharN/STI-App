part of 'login.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  }) {
    email.trim();
    password.trim();
  }
}
