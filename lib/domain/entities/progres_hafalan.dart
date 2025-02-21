import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';

part 'progres_hafalan.freezed.dart';
part 'progres_hafalan.g.dart';

@freezed
class ProgresHafalan with _$ProgresHafalan {
  static bool canManage(String role) => role == 'admin' || role == 'superAdmin';
  static bool canView(String role) => true;

  factory ProgresHafalan({
    required String id,
    required String userId,
    required String programId, // 'TAHFIDZ' atau 'GMM'
    @TimestampConverter() required DateTime tanggal,
    // Fields Tahfidz
    int? juz,
    int? halaman,
    int? ayat,
    String? surah,
    String? statusPenilaian, // Lancar/Belum/Perlu Perbaikan

    // Fields GMM
    String? iqroLevel, // Level 1-6
    int? iqroHalaman,
    String? statusIqro, // Lancar/Belum
    String? mutabaahTarget,
    String? statusMutabaah, // Tercapai/Belum

    String? catatan,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _ProgresHafalan;

  factory ProgresHafalan.validated({
    required String id,
    required String userId,
    required String programId,
    required DateTime tanggal,
    int? juz,
    int? halaman,
    int? ayat,
    String? surah,
    String? statusPenilaian,
    String? iqroLevel,
    int? iqroHalaman,
    String? statusIqro,
    String? mutabaahTarget,
    String? statusMutabaah,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    if (!['TAHFIDZ', 'GMM'].contains(programId)) {
      throw ArgumentError('Invalid program ID');
    }

    // Standardize timestamps
    final standardizedTanggal = TimestampConverter.standardizeDateTime(tanggal);
    if (standardizedTanggal == null ||
        !TimestampConverter.isValidTimestamp(standardizedTanggal)) {
      throw ArgumentError('Tanggal tidak valid');
    }

    final now = DateTime.now();
    final standardizedCreatedAt =
        TimestampConverter.standardizeDateTime(createdAt ?? now);
    final standardizedUpdatedAt =
        TimestampConverter.standardizeDateTime(updatedAt ?? now);

    if (programId == 'TAHFIDZ') {
      if (juz == null ||
          halaman == null ||
          ayat == null ||
          surah?.isEmpty == true ||
          statusPenilaian?.isEmpty == true) {
        throw ArgumentError('Incomplete Tahfidz progress data');
      }

      if (!['Lancar', 'Belum', 'Perlu Perbaikan'].contains(statusPenilaian)) {
        throw ArgumentError('Invalid status penilaian');
      }

      // Clear GMM fields
      iqroLevel = null;
      iqroHalaman = null;
      statusIqro = null;
      mutabaahTarget = null;
      statusMutabaah = null;
    } else {
      if (iqroLevel == null ||
          iqroHalaman == null ||
          statusIqro?.isEmpty == true ||
          mutabaahTarget?.isEmpty == true ||
          statusMutabaah?.isEmpty == true) {
        throw ArgumentError('Incomplete GMM progress data');
      }

      if (!['1', '2', '3', '4', '5', '6'].contains(iqroLevel)) {
        throw ArgumentError('Invalid iqro level');
      }

      if (!['Lancar', 'Belum'].contains(statusIqro)) {
        throw ArgumentError('Invalid status iqro');
      }

      if (!['Tercapai', 'Belum'].contains(statusMutabaah)) {
        throw ArgumentError('Invalid status mutabaah');
      }

      // Clear Tahfidz fields
      juz = null;
      halaman = null;
      ayat = null;
      surah = null;
      statusPenilaian = null;
    }

    return ProgresHafalan(
      id: id,
      userId: userId,
      programId: programId,
      tanggal: standardizedTanggal,
      juz: juz,
      halaman: halaman,
      ayat: ayat,
      surah: surah,
      statusPenilaian: statusPenilaian,
      iqroLevel: iqroLevel,
      iqroHalaman: iqroHalaman,
      statusIqro: statusIqro,
      mutabaahTarget: mutabaahTarget,
      statusMutabaah: statusMutabaah,
      catatan: catatan,
      createdAt: standardizedCreatedAt,
      updatedAt: standardizedUpdatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  factory ProgresHafalan.fromJson(Map<String, dynamic> json) =>
      _$ProgresHafalanFromJson(json);
}

extension ProgresHafalanX on ProgresHafalan {
  bool get isValid {
    if (userId.isEmpty || programId.isEmpty) return false;
    if (!TimestampConverter.isValidTimestamp(tanggal)) return false;

    if (programId == 'TAHFIDZ') {
      return juz != null &&
          halaman != null &&
          ayat != null &&
          surah?.isNotEmpty == true &&
          statusPenilaian?.isNotEmpty == true &&
          ['Lancar', 'Belum', 'Perlu Perbaikan'].contains(statusPenilaian);
    } else if (programId == 'GMM') {
      return iqroLevel != null &&
          iqroHalaman != null &&
          statusIqro?.isNotEmpty == true &&
          mutabaahTarget?.isNotEmpty == true &&
          statusMutabaah?.isNotEmpty == true &&
          ['1', '2', '3', '4', '5', '6'].contains(iqroLevel) &&
          ['Lancar', 'Belum'].contains(statusIqro) &&
          ['Tercapai', 'Belum'].contains(statusMutabaah);
    }

    return false;
  }

  bool canBeUpdatedBy(String role) => ProgresHafalan.canManage(role);
  bool canBeDeletedBy(String role) => ProgresHafalan.canManage(role);
}
