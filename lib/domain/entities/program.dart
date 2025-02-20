import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'program.freezed.dart';
part 'program.g.dart';

@freezed
class Program with _$Program {
  // Constants
  static const List<String> validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
  static const int maxTeachers = 3;

  factory Program({
    required String id,
    required String nama,
    required String deskripsi,
    required List<String> jadwal,
    String? lokasi,
    @Default([]) List<String> pengajarIds,
    @Default([]) List<String> pengajarNames,
    String? kelas,
    int? totalPertemuan,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default([]) List<String> enrolledSantriIds,
    @Default(true) bool isActive,
  }) = _Program;

  const Program._();

  // Program Validation
  bool get isValidProgram =>
      id.isNotEmpty &&
      nama.isNotEmpty &&
      deskripsi.isNotEmpty &&
      jadwal.isNotEmpty &&
      totalPertemuan != null &&
      totalPertemuan! > 0 &&
      validPrograms.contains(nama.toUpperCase());

  // Teacher Management
  bool get hasTeachers => pengajarIds.isNotEmpty;

  bool get canAddMoreTeachers => pengajarIds.length < maxTeachers;

  bool hasTeacher(String teacherId) => pengajarIds.contains(teacherId);

  bool isValidTeacherAddition(String teacherId) {
    if (!canAddMoreTeachers) return false;
    if (hasTeacher(teacherId)) return false;
    return true;
  }

  // Santri Management
  bool get hasSantri => enrolledSantriIds.isNotEmpty;

  bool hasSantriEnrolled(String santriId) =>
      enrolledSantriIds.contains(santriId);

  // Static Validators
  static bool isValidProgramName(String nama) {
    return validPrograms.contains(nama.toUpperCase());
  }

  static String getProgramDisplayName(String nama) {
    switch (nama.toUpperCase()) {
      case 'TAHFIDZ':
        return 'Program Tahfidz Al-Quran';
      case 'GMM':
        return 'Program Generasi Menghafal Mandiri';
      case 'IFIS':
        return 'Program Islamic Foundation and Islamic Studies';
      default:
        return 'Unknown Program';
    }
  }

  // Helper untuk validasi jadwal
  bool isValidSchedule(List<String> jadwalBaru) {
    // Cek duplikasi hari
    if (jadwalBaru.toSet().length != jadwalBaru.length) {
      return false;
    }

    // Validasi format hari
    final validDays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return jadwalBaru.every((day) => validDays.contains(day));
  }

  // Factory untuk JSON serialization
  factory Program.fromJson(Map<String, dynamic> json) =>
      _$ProgramFromJson(json);
}
