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
      pengajarIds: (json['pengajarIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pengajarNames: (json['pengajarNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      kelas: json['kelas'] as String?,
      totalPertemuan: (json['totalPertemuan'] as num?)?.toInt(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      enrolledSantriIds: (json['enrolledSantriIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ProgramImplToJson(_$ProgramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
      'deskripsi': instance.deskripsi,
      'jadwal': instance.jadwal,
      'lokasi': instance.lokasi,
      'pengajarIds': instance.pengajarIds,
      'pengajarNames': instance.pengajarNames,
      'kelas': instance.kelas,
      'totalPertemuan': instance.totalPertemuan,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'enrolledSantriIds': instance.enrolledSantriIds,
    };
