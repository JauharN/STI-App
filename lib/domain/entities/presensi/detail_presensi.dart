import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/json_converters.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';

part 'detail_presensi.freezed.dart';
part 'detail_presensi.g.dart';

@freezed
class DetailPresensi with _$DetailPresensi {
  static bool canAccess(String role) => true; // All roles can view details

  factory DetailPresensi({
    required String programId,
    required String programName,
    required String kelas,
    required String pengajarName,
    required List<PresensiDetailItem> pertemuan,
    @Default(null) PresensiSummary? summary,
  }) = _DetailPresensi;

  factory DetailPresensi.validated({
    required String programId,
    required String programName,
    required String kelas,
    required String pengajarName,
    required List<PresensiDetailItem> pertemuan,
    PresensiSummary? summary,
  }) {
    if (programId.isEmpty) {
      throw ArgumentError('Program ID tidak boleh kosong');
    }
    if (programName.isEmpty) {
      throw ArgumentError('Nama program tidak boleh kosong');
    }
    if (kelas.isEmpty) {
      throw ArgumentError('Kelas tidak boleh kosong');
    }
    if (pengajarName.isEmpty) {
      throw ArgumentError('Nama pengajar tidak boleh kosong');
    }
    if (pertemuan.isEmpty) {
      throw ArgumentError('Data pertemuan tidak boleh kosong');
    }

    // Validate all pertemuan dates
    for (var item in pertemuan) {
      if (!TimestampConverter.isValidTimestamp(item.tanggal)) {
        throw ArgumentError(
            'Tanggal pertemuan ke-${item.pertemuanKe} tidak valid');
      }
    }

    return DetailPresensi(
      programId: programId,
      programName: programName,
      kelas: kelas,
      pengajarName: pengajarName,
      pertemuan: pertemuan,
      summary: summary ??
          PresensiSummary(
            totalSantri: pertemuan.length,
            hadir: 0,
            sakit: 0,
            izin: 0,
            alpha: 0,
          ),
    );
  }

  factory DetailPresensi.fromJson(Map<String, dynamic> json) =>
      _$DetailPresensiFromJson(json);
}

@freezed
class PresensiDetailItem with _$PresensiDetailItem {
  factory PresensiDetailItem({
    required int pertemuanKe,
    required PresensiStatus status,
    @TimestampConverter() required DateTime tanggal,
    String? materi,
    String? keterangan,
  }) = _PresensiDetailItem;

  factory PresensiDetailItem.fromJson(Map<String, dynamic> json) =>
      _$PresensiDetailItemFromJson(json);
}

extension DetailPresensiX on DetailPresensi {
  /// Basic collection properties
  bool get isEmpty => pertemuan.isEmpty;
  bool get isNotEmpty => pertemuan.isNotEmpty;
  int get length => pertemuan.length;

  bool get isValid {
    if (programId.isEmpty ||
        programName.isEmpty ||
        kelas.isEmpty ||
        pengajarName.isEmpty) {
      return false;
    }
    if (pertemuan.isEmpty) return false;

    // Validate all pertemuan timestamps
    for (var item in pertemuan) {
      if (!TimestampConverter.isValidTimestamp(item.tanggal)) {
        return false;
      }
    }

    return true;
  }

  PresensiSummary calculateSummary() {
    int totalHadir = 0, totalSakit = 0, totalIzin = 0, totalAlpha = 0;

    for (var item in pertemuan) {
      switch (item.status) {
        case PresensiStatus.hadir:
          totalHadir++;
          break;
        case PresensiStatus.sakit:
          totalSakit++;
          break;
        case PresensiStatus.izin:
          totalIzin++;
          break;
        case PresensiStatus.alpha:
          totalAlpha++;
          break;
      }
    }

    return PresensiSummary(
      totalSantri: pertemuan.length,
      hadir: totalHadir,
      sakit: totalSakit,
      izin: totalIzin,
      alpha: totalAlpha,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get pertemuan sorted by tanggal
  List<PresensiDetailItem> get sortedPertemuan {
    final sorted = [...pertemuan];
    sorted.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    return sorted;
  }

  /// Get latest pertemuan based on tanggal
  PresensiDetailItem? get latestPertemuan {
    if (pertemuan.isEmpty) return null;
    return sortedPertemuan.last;
  }

  /// Get earliest pertemuan based on tanggal
  PresensiDetailItem? get firstPertemuan {
    if (pertemuan.isEmpty) return null;
    return sortedPertemuan.first;
  }

  /// Get pertemuan by pertemuanKe
  PresensiDetailItem? getPertemuanByNomor(int nomorPertemuan) {
    try {
      return pertemuan.firstWhere(
        (p) => p.pertemuanKe == nomorPertemuan,
      );
    } catch (_) {
      return null;
    }
  }
}
