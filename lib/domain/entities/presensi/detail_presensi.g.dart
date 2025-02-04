// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_presensi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetailPresensiImpl _$$DetailPresensiImplFromJson(Map<String, dynamic> json) =>
    _$DetailPresensiImpl(
      programId: json['programId'] as String,
      programName: json['programName'] as String,
      kelas: json['kelas'] as String,
      pengajarName: json['pengajarName'] as String,
      pertemuan: (json['pertemuan'] as List<dynamic>)
          .map((e) => PresensiDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] == null
          ? null
          : PresensiSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DetailPresensiImplToJson(
        _$DetailPresensiImpl instance) =>
    <String, dynamic>{
      'programId': instance.programId,
      'programName': instance.programName,
      'kelas': instance.kelas,
      'pengajarName': instance.pengajarName,
      'pertemuan': instance.pertemuan,
      'summary': instance.summary,
    };

_$PresensiDetailItemImpl _$$PresensiDetailItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PresensiDetailItemImpl(
      pertemuanKe: (json['pertemuanKe'] as num).toInt(),
      status: $enumDecode(_$PresensiStatusEnumMap, json['status']),
      tanggal: DateTime.parse(json['tanggal'] as String),
      materi: json['materi'] as String?,
      keterangan: json['keterangan'] as String?,
    );

Map<String, dynamic> _$$PresensiDetailItemImplToJson(
        _$PresensiDetailItemImpl instance) =>
    <String, dynamic>{
      'pertemuanKe': instance.pertemuanKe,
      'status': instance.status,
      'tanggal': instance.tanggal.toIso8601String(),
      'materi': instance.materi,
      'keterangan': instance.keterangan,
    };

const _$PresensiStatusEnumMap = {
  PresensiStatus.hadir: 'hadir',
  PresensiStatus.sakit: 'sakit',
  PresensiStatus.izin: 'izin',
  PresensiStatus.alpha: 'alpha',
};
