// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_presensi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SantriPresensiImpl _$$SantriPresensiImplFromJson(Map<String, dynamic> json) =>
    _$SantriPresensiImpl(
      santriId: json['santriId'] as String,
      santriName: json['santriName'] as String,
      status: $enumDecode(_$PresensiStatusEnumMap, json['status']),
      keterangan: json['keterangan'] as String?,
    );

Map<String, dynamic> _$$SantriPresensiImplToJson(
        _$SantriPresensiImpl instance) =>
    <String, dynamic>{
      'santriId': instance.santriId,
      'santriName': instance.santriName,
      'status': _$PresensiStatusEnumMap[instance.status]!,
      'keterangan': instance.keterangan,
    };

const _$PresensiStatusEnumMap = {
  PresensiStatus.hadir: 'hadir',
  PresensiStatus.sakit: 'sakit',
  PresensiStatus.izin: 'izin',
  PresensiStatus.alpha: 'alpha',
};
