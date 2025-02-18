import '../../domain/entities/result.dart';

abstract interface class Authentication {
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required List<String> selectedPrograms,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  });

  Future<Result<String>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  String? getLoggedUserId();

  // Tambahkan method untuk validasi session
  Future<Result<bool>> isSessionValid();

  // Tambahkan method untuk refresh token jika diperlukan
  Future<Result<void>> refreshToken();

  // Method untuk validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Method untuk validate password strength
  static bool isValidPassword(String password) {
    // Minimal 6 karakter, harus ada kombinasi huruf dan angka
    return password.length >= 6 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password);
  }

  // Helper untuk sanitasi input
  static String sanitizeEmail(String email) => email.trim().toLowerCase();
  static String sanitizeName(String name) => name.trim();
  static String sanitizePhoneNumber(String? phone) => phone?.trim() ?? '';
  static String sanitizeAddress(String? address) => address?.trim() ?? '';
}
