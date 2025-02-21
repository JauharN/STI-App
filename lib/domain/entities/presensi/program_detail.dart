import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';

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
    @Default([]) List<String> teacherIds,
    @Default([]) List<String> teacherNames,
    @Default([]) List<String> enrolledSantriIds,
    @TimestampConverter() @Default(null) DateTime? createdAt,
    @TimestampConverter() @Default(null) DateTime? updatedAt,
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

    // Validasi timestamps
    final now = DateTime.now();

    if (createdAt != null) {
      if (createdAt.isAfter(now)) {
        throw ArgumentError('Tanggal pembuatan tidak boleh di masa depan');
      }
    }

    if (updatedAt != null) {
      if (updatedAt.isAfter(now)) {
        throw ArgumentError('Tanggal update tidak boleh di masa depan');
      }
      if (createdAt != null && updatedAt.isBefore(createdAt)) {
        throw ArgumentError(
            'Tanggal update tidak boleh sebelum tanggal pembuatan');
      }
    }

    // Validasi teacher lists jika ada
    if (teacherIds != null && teacherNames != null) {
      if (teacherIds.length != teacherNames.length) {
        throw ArgumentError('Jumlah ID dan nama pengajar harus sama');
      }
      if (teacherIds.length > 3) {
        throw ArgumentError('Maksimal 3 pengajar per program');
      }
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
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
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

  bool get hasTeachers => teacherIds.isNotEmpty;
  bool get hasEnrolledSantri => enrolledSantriIds.isNotEmpty;

  bool get isDateValid {
    final now = DateTime.now();

    if (createdAt != null && createdAt!.isAfter(now)) {
      return false;
    }

    if (updatedAt != null) {
      if (updatedAt!.isAfter(now)) return false;
      if (createdAt != null && updatedAt!.isBefore(createdAt!)) return false;
    }

    return true;
  }
}
