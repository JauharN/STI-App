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
    @Default([]) List<String> teacherIds, // Ubah ke list
    @Default([]) List<String> teacherNames, // Ubah ke list
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
    List<String>? teacherIds,
    List<String>? teacherNames,
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

    return ProgramDetail(
      id: id,
      name: name,
      description: description,
      schedule: schedule,
      totalMeetings: totalMeetings,
      location: location,
      teacherIds: teacherIds ?? [],
      teacherNames: teacherNames ?? [],
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
    return true;
  }

  bool get hasTeachers => teacherIds.isNotEmpty; // Update check
  bool get hasEnrolledSantri => enrolledSantriIds.isNotEmpty;
}
