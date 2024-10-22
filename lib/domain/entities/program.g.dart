// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgramImpl _$$ProgramImplFromJson(Map<String, dynamic> json) =>
    _$ProgramImpl(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      jadwal:
          (json['jadwal'] as List<dynamic>).map((e) => e as String).toList(),
      lokasi: json['lokasi'] as String?,
    );

Map<String, dynamic> _$$ProgramImplToJson(_$ProgramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
      'deskripsi': instance.deskripsi,
      'jadwal': instance.jadwal,
      'lokasi': instance.lokasi,
    };
