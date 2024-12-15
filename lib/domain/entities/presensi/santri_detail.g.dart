// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SantriDetailImpl _$$SantriDetailImplFromJson(Map<String, dynamic> json) =>
    _$SantriDetailImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      enrolledPrograms: (json['enrolledPrograms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SantriDetailImplToJson(_$SantriDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'enrolledPrograms': instance.enrolledPrograms,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'isActive': instance.isActive,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
