// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_statistics_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresensiStatisticsDataImpl _$$PresensiStatisticsDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PresensiStatisticsDataImpl(
      programId: json['programId'] as String,
      totalPertemuan: (json['totalPertemuan'] as num).toInt(),
      totalSantri: (json['totalSantri'] as num).toInt(),
      trendKehadiran: (json['trendKehadiran'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      totalByStatus: (json['totalByStatus'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$PresensiStatusEnumMap, k), (e as num).toInt()),
      ),
      santriStats: (json['santriStats'] as List<dynamic>)
          .map((e) => SantriStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$PresensiStatisticsDataImplToJson(
        _$PresensiStatisticsDataImpl instance) =>
    <String, dynamic>{
      'programId': instance.programId,
      'totalPertemuan': instance.totalPertemuan,
      'totalSantri': instance.totalSantri,
      'trendKehadiran': instance.trendKehadiran,
      'totalByStatus': instance.totalByStatus,
      'santriStats': instance.santriStats,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

const _$PresensiStatusEnumMap = {
  PresensiStatus.hadir: 'hadir',
  PresensiStatus.sakit: 'sakit',
  PresensiStatus.izin: 'izin',
  PresensiStatus.alpha: 'alpha',
};
