// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresensiSummaryImpl _$$PresensiSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$PresensiSummaryImpl(
      totalSantri: (json['totalSantri'] as num).toInt(),
      hadir: (json['hadir'] as num).toInt(),
      sakit: (json['sakit'] as num).toInt(),
      izin: (json['izin'] as num).toInt(),
      alpha: (json['alpha'] as num).toInt(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$PresensiSummaryImplToJson(
        _$PresensiSummaryImpl instance) =>
    <String, dynamic>{
      'totalSantri': instance.totalSantri,
      'hadir': instance.hadir,
      'sakit': instance.sakit,
      'izin': instance.izin,
      'alpha': instance.alpha,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
