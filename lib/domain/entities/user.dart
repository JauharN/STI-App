import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  static const List<String> validRoles = ['superAdmin', 'admin', 'santri'];
  static const List<String> validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];

  factory User({
    required String uid,
    required String name,
    required String email,
    @Default('santri') String role,
    @Default(true) bool isActive,
    @Default([]) List<String> enrolledPrograms,
    String? photoUrl,
    String? phoneNumber,
    @TimestampConverter() DateTime? dateOfBirth,
    String? address,
  }) = _User;

  const User._();

  static bool isValidRole(String role) {
    return validRoles.contains(role.toLowerCase());
  }

  static bool isValidProgram(String program) {
    return validPrograms.contains(program.toUpperCase());
  }

  static bool areValidPrograms(List<String> programs) {
    return programs.every((program) => isValidProgram(program));
  }

  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'santri':
        return 'Santri';
      default:
        return 'Unknown Role';
    }
  }

  static String getProgramDisplayName(String program) {
    switch (program.toUpperCase()) {
      case 'TAHFIDZ':
        return 'Program Tahfidz';
      case 'GMM':
        return 'Generasi Menghafal Mandiri';
      case 'IFIS':
        return 'Islamic Foundation & Islamic Studies';
      default:
        return 'Unknown Program';
    }
  }

  bool canAccessProgram(String program) {
    if (role == 'superAdmin' || role == 'admin') return true;
    return enrolledPrograms.contains(program.toUpperCase());
  }

  bool hasAnyProgram() => enrolledPrograms.isNotEmpty;

  bool hasProgram(String program) =>
      enrolledPrograms.contains(program.toUpperCase());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
