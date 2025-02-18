import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'program.freezed.dart';
part 'program.g.dart';

@freezed
class Program with _$Program {
  factory Program({
    required String id,
    required String nama, // TAHFIDZ, GMM, IFIS
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
  }) = _Program;

  const Program._();

  // Add helpers untuk validasi
  bool get hasTeachers => pengajarIds.isNotEmpty;

  bool get isValidProgram =>
      id.isNotEmpty &&
      nama.isNotEmpty &&
      deskripsi.isNotEmpty &&
      jadwal.isNotEmpty &&
      totalPertemuan != null &&
      totalPertemuan! > 0;

  // Helper untuk cek pengajar
  bool hasTeacher(String teacherId) => pengajarIds.contains(teacherId);

  // Helper untuk cek santri
  bool hasSantri(String santriId) => enrolledSantriIds.contains(santriId);

  // Static validators
  static bool isValidProgramName(String nama) {
    return ['TAHFIDZ', 'GMM', 'IFIS'].contains(nama.toUpperCase());
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

  // Factory untuk JSON serialization
  factory Program.fromJson(Map<String, dynamic> json) =>
      _$ProgramFromJson(json);
}
