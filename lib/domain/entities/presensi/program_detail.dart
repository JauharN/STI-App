import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_detail.freezed.dart';
part 'program_detail.g.dart';

@freezed
class ProgramDetail with _$ProgramDetail {
  factory ProgramDetail({
    required String id,
    required String name,
    required String description,
    required List<String> schedule,
    required int totalMeetings,
    String? location,
    String? teacherId,
    String? teacherName,
    List<String>? enrolledSantriIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProgramDetail;

  factory ProgramDetail.fromJson(Map<String, dynamic> json) =>
      _$ProgramDetailFromJson(json);
}
