import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  factory User({
    required String uid,
    required String name,
    required String email,
    required String role, // 'santri' atau 'admin'
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
