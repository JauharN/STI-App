import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';

part 'santri_detail.freezed.dart';
part 'santri_detail.g.dart';

@freezed
class SantriDetail with _$SantriDetail {
  static bool canAccess(String role) =>
      role == 'admin' || role == 'superAdmin' || role == 'santri';

  factory SantriDetail({
    required String id,
    required String name,
    required String email,
    required List<String> enrolledPrograms,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    @Default(true) bool isActive,
    @TimestampConverter() DateTime? dateOfBirth,
    @TimestampConverter() @Default(null) DateTime? createdAt,
    @TimestampConverter() @Default(null) DateTime? updatedAt,
  }) = _SantriDetail;

  factory SantriDetail.validated({
    required String id,
    required String name,
    required String email,
    required List<String> enrolledPrograms,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    bool isActive = true,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (id.isEmpty || name.isEmpty || email.isEmpty) {
      throw ArgumentError('ID, nama, dan email tidak boleh kosong');
    }

    if (!email.contains('@')) {
      throw ArgumentError('Format email tidak valid');
    }

    if (enrolledPrograms.isEmpty) {
      throw ArgumentError('Santri harus terdaftar minimal di satu program');
    }

    // Standardize timestamps
    final standardizedDateOfBirth = dateOfBirth != null
        ? TimestampConverter.standardizeDateTime(dateOfBirth)
        : null;

    final now = DateTime.now();
    final standardizedCreatedAt =
        TimestampConverter.standardizeDateTime(createdAt ?? now);
    final standardizedUpdatedAt =
        TimestampConverter.standardizeDateTime(updatedAt ?? now);

    // Validate date of birth if provided
    if (standardizedDateOfBirth != null) {
      if (!TimestampConverter.isValidTimestamp(standardizedDateOfBirth)) {
        throw ArgumentError('Tanggal lahir tidak valid');
      }

      final minimumAge = now.subtract(const Duration(days: 365 * 5));
      final maximumAge = now.subtract(const Duration(days: 365 * 50));

      if (standardizedDateOfBirth.isAfter(minimumAge)) {
        throw ArgumentError('Umur minimal 5 tahun');
      }

      if (standardizedDateOfBirth.isBefore(maximumAge)) {
        throw ArgumentError('Umur tidak valid');
      }
    }

    return SantriDetail(
      id: id,
      name: name,
      email: email,
      enrolledPrograms: enrolledPrograms,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      address: address,
      isActive: isActive,
      dateOfBirth: standardizedDateOfBirth,
      createdAt: standardizedCreatedAt,
      updatedAt: standardizedUpdatedAt,
    );
  }

  factory SantriDetail.fromJson(Map<String, dynamic> json) =>
      _$SantriDetailFromJson(json);
}

extension SantriDetailX on SantriDetail {
  bool get isValid {
    if (id.isEmpty || name.isEmpty || email.isEmpty) return false;
    if (!email.contains('@')) return false;
    if (enrolledPrograms.isEmpty) return false;

    // Date of birth validation if exists
    if (dateOfBirth != null &&
        !TimestampConverter.isValidTimestamp(dateOfBirth!)) {
      return false;
    }

    return true;
  }

  bool get canViewPresensi => isActive;
}
