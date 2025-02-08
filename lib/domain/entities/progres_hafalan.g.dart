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
      tanggal: DateTime.parse(json['tanggal'] as String),
      juz: (json['juz'] as num?)?.toInt(),
      halaman: (json['halaman'] as num?)?.toInt(),
      ayat: (json['ayat'] as num?)?.toInt(),
      surah: json['surah'] as String?,
      statusPenilaian: json['statusPenilaian'] as String?,
      iqroLevel: json['iqroLevel'] as String?,
      iqroHalaman: (json['iqroHalaman'] as num?)?.toInt(),
      statusIqro: json['statusIqro'] as String?,
      mutabaahTarget: json['mutabaahTarget'] as String?,
      statusMutabaah: json['statusMutabaah'] as String?,
      catatan: json['catatan'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$$ProgresHafalanImplToJson(
        _$ProgresHafalanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'programId': instance.programId,
      'tanggal': instance.tanggal.toIso8601String(),
      'juz': instance.juz,
      'halaman': instance.halaman,
      'ayat': instance.ayat,
      'surah': instance.surah,
      'statusPenilaian': instance.statusPenilaian,
      'iqroLevel': instance.iqroLevel,
      'iqroHalaman': instance.iqroHalaman,
      'statusIqro': instance.statusIqro,
      'mutabaahTarget': instance.mutabaahTarget,
      'statusMutabaah': instance.statusMutabaah,
      'catatan': instance.catatan,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
    };
