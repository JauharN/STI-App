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
      teacherIds: (json['teacherIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      teacherNames: (json['teacherNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      enrolledSantriIds: (json['enrolledSantriIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
      'teacherIds': instance.teacherIds,
      'teacherNames': instance.teacherNames,
      'enrolledSantriIds': instance.enrolledSantriIds,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
