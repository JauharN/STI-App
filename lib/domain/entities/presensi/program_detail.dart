import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_detail.freezed.dart';
part 'program_detail.g.dart';

@freezed
class ProgramDetail with _$ProgramDetail {
  static bool canManage(String role) => role == 'admin' || role == 'superAdmin';

  static bool canView(String role) => true;

  factory ProgramDetail({
    required String id,
    required String name,
    required String description,
    required List<String> schedule,
    required int totalMeetings,
    String? location,
    String? teacherId,
    String? teacherName,
    @Default([]) List<String> enrolledSantriIds,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _ProgramDetail;

  factory ProgramDetail.validated({
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
  }) {
    if (id.isEmpty || name.isEmpty || description.isEmpty) {
      throw ArgumentError('ID, nama, dan deskripsi program tidak boleh kosong');
    }
    if (schedule.isEmpty) {
      throw ArgumentError('Jadwal program tidak boleh kosong');
    }
    if (totalMeetings <= 0) {
      throw ArgumentError('Total pertemuan harus lebih dari 0');
    }
    if (teacherId != null && teacherId.isEmpty) {
      throw ArgumentError('ID pengajar tidak valid');
    }

    return ProgramDetail(
      id: id,
      name: name,
      description: description,
      schedule: schedule,
      totalMeetings: totalMeetings,
      location: location,
      teacherId: teacherId,
      teacherName: teacherName,
      enrolledSantriIds: enrolledSantriIds ?? [],
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory ProgramDetail.fromJson(Map<String, dynamic> json) =>
      _$ProgramDetailFromJson(json);
}

extension ProgramDetailX on ProgramDetail {
  bool get isValid {
    if (id.isEmpty || name.isEmpty || description.isEmpty) return false;
    if (schedule.isEmpty || totalMeetings <= 0) return false;
    if (teacherId != null && teacherId!.isEmpty) return false;
    return true;
  }

  bool get hasTeacher => teacherId != null && teacherName != null;
  bool get hasEnrolledSantri => enrolledSantriIds.isNotEmpty;
}
