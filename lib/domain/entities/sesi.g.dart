// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SesiImpl _$$SesiImplFromJson(Map<String, dynamic> json) => _$SesiImpl(
      id: json['id'] as String,
      programId: json['programId'] as String,
      waktuMulai: DateTime.parse(json['waktuMulai'] as String),
      waktuSelesai: DateTime.parse(json['waktuSelesai'] as String),
      pengajarId: json['pengajarId'] as String,
      materi: json['materi'] as String?,
      catatan: json['catatan'] as String?,
    );

Map<String, dynamic> _$$SesiImplToJson(_$SesiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programId': instance.programId,
      'waktuMulai': instance.waktuMulai.toIso8601String(),
      'waktuSelesai': instance.waktuSelesai.toIso8601String(),
      'pengajarId': instance.pengajarId,
      'materi': instance.materi,
      'catatan': instance.catatan,
    };
