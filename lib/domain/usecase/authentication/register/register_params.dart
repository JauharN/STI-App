part of 'register.dart';

class RegisterParams {
  static final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static const int minPasswordLength = 6;

  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role, // Tetap terima untuk kompatibilitas
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
  }) {
    // Validasi yang lebih robust
    final validationErrors = <String>[];

    if (name.trim().isEmpty) {
      validationErrors.add('Name cannot be empty');
    }

    if (!emailRegex.hasMatch(email.trim())) {
      validationErrors.add('Invalid email format');
    }

    if (password.length < minPasswordLength) {
      validationErrors
          .add('Password must be at least $minPasswordLength characters');
    }

    // Validasi phoneNumber jika ada
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\-\s]{10,13}$').hasMatch(phoneNumber!)) {
        validationErrors.add('Invalid phone number format (10-13 digits)');
      }
    }

    // Validasi dateOfBirth jika ada
    if (dateOfBirth != null) {
      if (dateOfBirth!.isAfter(DateTime.now())) {
        validationErrors.add('Date of birth cannot be in the future');
      }
      // Tambahan: validasi umur minimum jika diperlukan
      final minimumAge = DateTime.now().subtract(const Duration(days: 365 * 5));
      if (dateOfBirth!.isAfter(minimumAge)) {
        validationErrors.add('Minimum age requirement not met');
      }
    }

    if (validationErrors.isNotEmpty) {
      throw ArgumentError(validationErrors.join(', '));
    }
  }

  // Sanitized getters untuk memastikan data bersih
  String get sanitizedName => name.trim();
  String get sanitizedEmail => email.trim().toLowerCase();
  String get sanitizedPhoneNumber => phoneNumber?.trim() ?? '';
  String get sanitizedAddress => address?.trim() ?? '';
}
