// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SantriStatisticsImpl _$$SantriStatisticsImplFromJson(
        Map<String, dynamic> json) =>
    _$SantriStatisticsImpl(
      santriId: json['santriId'] as String,
      santriName: json['santriName'] as String,
      totalKehadiran: (json['totalKehadiran'] as num).toInt(),
      totalPertemuan: (json['totalPertemuan'] as num).toInt(),
      statusCount: (json['statusCount'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$PresensiStatusEnumMap, k), (e as num).toInt()),
      ),
      persentaseKehadiran: (json['persentaseKehadiran'] as num).toDouble(),
    );

Map<String, dynamic> _$$SantriStatisticsImplToJson(
        _$SantriStatisticsImpl instance) =>
    <String, dynamic>{
      'santriId': instance.santriId,
      'santriName': instance.santriName,
      'totalKehadiran': instance.totalKehadiran,
      'totalPertemuan': instance.totalPertemuan,
      'statusCount': instance.statusCount
          .map((k, e) => MapEntry(_$PresensiStatusEnumMap[k]!, e)),
      'persentaseKehadiran': instance.persentaseKehadiran,
    };

const _$PresensiStatusEnumMap = {
  PresensiStatus.hadir: 'hadir',
  PresensiStatus.sakit: 'sakit',
  PresensiStatus.izin: 'izin',
  PresensiStatus.alpha: 'alpha',
};
