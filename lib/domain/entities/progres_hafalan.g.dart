// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progres_hafalan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgresHafalanImpl _$$ProgresHafalanImplFromJson(Map<String, dynamic> json) =>
    _$ProgresHafalanImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      programId: json['programId'] as String,
      juz: (json['juz'] as num?)?.toInt(),
      halaman: (json['halaman'] as num?)?.toInt(),
      ayat: (json['ayat'] as num?)?.toInt(),
      iqroLevel: json['iqroLevel'] as String?,
      iqroHalaman: (json['iqroHalaman'] as num?)?.toInt(),
      mutabaahTarget: json['mutabaahTarget'] as String?,
      tanggal: DateTime.parse(json['tanggal'] as String),
      catatan: json['catatan'] as String?,
    );

Map<String, dynamic> _$$ProgresHafalanImplToJson(
        _$ProgresHafalanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'programId': instance.programId,
      'juz': instance.juz,
      'halaman': instance.halaman,
      'ayat': instance.ayat,
      'iqroLevel': instance.iqroLevel,
      'iqroHalaman': instance.iqroHalaman,
      'mutabaahTarget': instance.mutabaahTarget,
      'tanggal': instance.tanggal.toIso8601String(),
      'catatan': instance.catatan,
    };
