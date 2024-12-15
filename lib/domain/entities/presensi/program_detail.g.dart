// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgramDetailImpl _$$ProgramDetailImplFromJson(Map<String, dynamic> json) =>
    _$ProgramDetailImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      schedule:
          (json['schedule'] as List<dynamic>).map((e) => e as String).toList(),
      totalMeetings: (json['totalMeetings'] as num).toInt(),
      location: json['location'] as String?,
      teacherId: json['teacherId'] as String?,
      teacherName: json['teacherName'] as String?,
      enrolledSantriIds: (json['enrolledSantriIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProgramDetailImplToJson(_$ProgramDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'schedule': instance.schedule,
      'totalMeetings': instance.totalMeetings,
      'location': instance.location,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'enrolledSantriIds': instance.enrolledSantriIds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
