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
      // Role validation
      if (!PresensiPertemuan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat membuat presensi');
      }

      // Validate daftar hadir
      if (params.daftarHadir.isEmpty) {
        return const Result.failed('Daftar hadir tidak boleh kosong');
      }

      // Create presensi object with generated summary
      final presensiPertemuan = PresensiPertemuan(
        id: '', // ID akan digenerate oleh Firebase
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
        tanggal: params.tanggal,
        daftarHadir: params.daftarHadir,
        summary: _generateSummary(params.daftarHadir),
        materi: params.materi,
        catatan: params.catatan,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: params.userId,
        updatedBy: params.userId,
      );

      // Save to repository
      return await _presensiRepository
          .createPresensiPertemuan(presensiPertemuan);
    } catch (e) {
      return Result.failed('Gagal membuat presensi: ${e.toString()}');
    }
  }

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
      updatedAt: DateTime.now(),
    );
  }
}
