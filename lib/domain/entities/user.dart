import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@JsonEnum()
enum UserRole {
  @JsonValue('superAdmin')
  superAdmin,
  @JsonValue('admin')
  admin,
  @JsonValue('santri')
  santri;

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
}

@freezed
class User with _$User {
  factory User({
    required String uid,
    required String name,
    required String email,
    @Default(UserRole.santri) UserRole role,
    @Default(true) bool isActive,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
