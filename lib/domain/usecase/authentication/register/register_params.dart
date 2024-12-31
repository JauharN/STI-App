class RegisterParams {
  final String name;
  final String email;
  final String password;

  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
  });
}
