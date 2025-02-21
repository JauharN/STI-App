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
      dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
      createdAt: json['createdAt'] == null
          ? null
          : const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: json['updatedAt'] == null
          ? null
          : const TimestampConverter().fromJson(json['updatedAt']),
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
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
