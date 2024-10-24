class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? photoUrl;

  RegisterParams(
      {required this.name,
      required this.email,
      required this.password,
      required this.role,
      this.photoUrl});
}
