import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../usecase.dart';

part 'create_presensi_pertemuan_params.dart';

class CreatePresensiPertemuan
    implements
        Usecase<Result<PresensiPertemuan>, CreatePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  CreatePresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      CreatePresensiPertemuanParams params) async {
    try {
      // Generate summary dari daftarHadir
      final summary = _generateSummary(params.daftarHadir);

      // Buat PresensiPertemuan baru dengan summary
      final presensiPertemuan = PresensiPertemuan(
        id: '', // akan digenerate oleh Firebase
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
        tanggal: params.tanggal,
        daftarHadir: params.daftarHadir,
        summary: summary,
        materi: params.materi,
        catatan: params.catatan,
      );

      return await _presensiRepository
          .createPresensiPertemuan(presensiPertemuan);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  // Helper method untuk generate summary
  PresensiSummary _generateSummary(List<SantriPresensi> daftarHadir) {
    int hadir = 0, sakit = 0, izin = 0, alpha = 0;

    for (var santri in daftarHadir) {
      switch (santri.status) {
        case PresensiStatus.hadir:
          hadir++;
          break;
        case PresensiStatus.sakit:
          sakit++;
          break;
        case PresensiStatus.izin:
          izin++;
          break;
        case PresensiStatus.alpha:
          alpha++;
          break;
      }
    }

    return PresensiSummary(
        totalSantri: daftarHadir.length,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }
}
