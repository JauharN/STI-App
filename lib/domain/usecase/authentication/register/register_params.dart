part of 'register.dart';

class RegisterParams {
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static const int minPasswordLength = 6;

  final String name;
  final String email;
  final String password;
  final String role;
  final List<String> selectedPrograms;
  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    String? role,
    List<String>? selectedPrograms,
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
  })  : role = role ?? 'santri',
        selectedPrograms = selectedPrograms ?? [] {
    final validationErrors = <String>[];

    // Validasi email dan password
    if (name.trim().isEmpty) {
      validationErrors.add('Nama tidak boleh kosong');
    }

    if (!emailRegex.hasMatch(email.trim())) {
      validationErrors.add('Format email tidak valid');
    }

    if (password.length < minPasswordLength) {
      validationErrors.add('Password minimal $minPasswordLength karakter');
    }

    // Validasi role
    if (!User.isValidRole(this.role)) {
      validationErrors.add('Role tidak valid');
    }

    // Validasi program khusus santri
    if (this.role == 'santri') {
      // Harus pilih minimal 1 program
      if (this.selectedPrograms.isEmpty) {
        validationErrors.add('Santri harus memilih minimal 1 program');
      }

      // Validasi setiap program yang dipilih
      if (!User.areValidPrograms(this.selectedPrograms)) {
        validationErrors.add('Program yang dipilih tidak valid');
      }

      // Maksimal pilih 3 program
      if (this.selectedPrograms.length > 3) {
        validationErrors.add('Maksimal pilih 3 program');
      }

      // Cek duplikasi program
      if (this.selectedPrograms.toSet().length !=
          this.selectedPrograms.length) {
        validationErrors.add('Program tidak boleh duplikat');
      }
    }

    // Validasi format nomor telepon jika ada
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\-\s]{10,13}$').hasMatch(phoneNumber!)) {
        validationErrors.add('Format nomor telepon tidak valid (10-13 digit)');
      }
    }

    // Validasi tanggal lahir jika ada
    if (dateOfBirth != null) {
      if (dateOfBirth!.isAfter(DateTime.now())) {
        validationErrors.add('Tanggal lahir tidak boleh di masa depan');
      }

      final minimumAge = DateTime.now().subtract(const Duration(days: 365 * 5));
      if (dateOfBirth!.isAfter(minimumAge)) {
        validationErrors.add('Umur minimal 5 tahun');
      }
    }

    if (validationErrors.isNotEmpty) {
      throw ArgumentError(validationErrors.join(', '));
    }
  }

  // Helper methods untuk sanitasi data
  String get sanitizedName => name.trim();
  String get sanitizedEmail => email.trim().toLowerCase();
  String get sanitizedPhoneNumber => phoneNumber?.trim() ?? '';
  String get sanitizedAddress => address?.trim() ?? '';

  // Helper untuk cek program spesifik
  bool hasProgram(String program) =>
      selectedPrograms.contains(program.toUpperCase());

  // Helper untuk mendapatkan total program
  int get totalPrograms => selectedPrograms.length;

  // Helper untuk cek program tertentu tidak bisa diambil bersamaan
  bool hasIncompatiblePrograms() {
    final hasIfis = hasProgram('IFIS');
    final hasGmm = hasProgram('GMM');
    return hasIfis && hasGmm; // IFIS dan GMM tidak bisa diambil bersamaan
  }
}
