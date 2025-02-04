import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  static const List<String> validRoles = ['superAdmin', 'admin', 'santri'];

  factory User({
    required String uid,
    required String name,
    required String email,
    @Default('santri') String role,
    @Default(true) bool isActive,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
  }) = _User;

  // Add validation method
  static bool isValidRole(String role) {
    return validRoles.contains(role.toLowerCase());
  }

  // Add helper method to get display name
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
