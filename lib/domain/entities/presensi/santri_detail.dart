import 'package:freezed_annotation/freezed_annotation.dart';

part 'santri_detail.freezed.dart';
part 'santri_detail.g.dart';

@freezed
class SantriDetail with _$SantriDetail {
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SantriDetail;

  factory SantriDetail.fromJson(Map<String, dynamic> json) =>
      _$SantriDetailFromJson(json);
}
