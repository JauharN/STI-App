import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@JsonEnum()
enum UserRole {
  @JsonValue('santri')
  santri,
  @JsonValue('admin')
  admin,
  @JsonValue('superAdmin')
  superAdmin;

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.santri:
        return 'Santri';
    }
  }

  String toJson() {
    return switch (this) {
      UserRole.santri => 'santri',
      UserRole.admin => 'admin',
      UserRole.superAdmin => 'superAdmin',
    };
  }

  static UserRole fromJson(String value) {
    return switch (value.toLowerCase()) {
      'santri' => UserRole.santri,
      'admin' => UserRole.admin,
      'superadmin' => UserRole.superAdmin,
      _ => UserRole.santri,
    };
  }
}

@freezed
class User with _$User {
  factory User({
    required String uid,
    required String name,
    required String email,
    @Default(UserRole.santri)
    @JsonKey(toJson: _userRoleToJson, fromJson: _userRoleFromJson)
    UserRole role,
    @Default(true) bool isActive,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

String _userRoleToJson(UserRole role) => role.toJson();
UserRole _userRoleFromJson(String value) => UserRole.fromJson(value);
