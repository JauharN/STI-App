// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_pertemuan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresensiPertemuanImpl _$$PresensiPertemuanImplFromJson(
        Map<String, dynamic> json) =>
    _$PresensiPertemuanImpl(
      id: json['id'] as String,
      programId: json['programId'] as String,
      pertemuanKe: (json['pertemuanKe'] as num).toInt(),
      tanggal: DateTime.parse(json['tanggal'] as String),
      daftarHadir: (json['daftarHadir'] as List<dynamic>)
          .map((e) => SantriPresensi.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          PresensiSummary.fromJson(json['summary'] as Map<String, dynamic>),
      materi: json['materi'] as String?,
      catatan: json['catatan'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: json['updatedAt'] == null
          ? null
          : const TimestampConverter().fromJson(json['updatedAt']),
      createdBy: json['createdBy'] as String? ?? null,
      updatedBy: json['updatedBy'] as String? ?? null,
    );

Map<String, dynamic> _$$PresensiPertemuanImplToJson(
        _$PresensiPertemuanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programId': instance.programId,
      'pertemuanKe': instance.pertemuanKe,
      'tanggal': instance.tanggal.toIso8601String(),
      'daftarHadir': instance.daftarHadir,
      'summary': instance.summary,
      'materi': instance.materi,
      'catatan': instance.catatan,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
    };
