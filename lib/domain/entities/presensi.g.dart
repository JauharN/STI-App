// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresensiImpl _$$PresensiImplFromJson(Map<String, dynamic> json) =>
    _$PresensiImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      programId: json['programId'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      status: json['status'] as String,
      keterangan: json['keterangan'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PresensiImplToJson(_$PresensiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'programId': instance.programId,
      'tanggal': instance.tanggal.toIso8601String(),
      'status': instance.status,
      'keterangan': instance.keterangan,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
