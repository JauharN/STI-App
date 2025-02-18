// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'santri',
      isActive: json['isActive'] as bool? ?? true,
      enrolledPrograms: (json['enrolledPrograms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'isActive': instance.isActive,
      'enrolledPrograms': instance.enrolledPrograms,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'address': instance.address,
    };
