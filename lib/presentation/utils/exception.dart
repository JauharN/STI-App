class LoginException implements Exception {
  final String message;
  LoginException(this.message);
  @override
  String toString() => message;
}

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);
  @override
  String toString() => message;
}
