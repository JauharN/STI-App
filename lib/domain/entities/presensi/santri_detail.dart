import 'package:freezed_annotation/freezed_annotation.dart';

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
    DateTime? dateOfBirth,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
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

    return SantriDetail(
      id: id,
      name: name,
      email: email,
      enrolledPrograms: enrolledPrograms,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      address: address,
      isActive: isActive,
      dateOfBirth: dateOfBirth,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
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
    return true;
  }

  bool get canViewPresensi => isActive;
}
