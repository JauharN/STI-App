import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../../entities/user.dart';
import '../../usecase.dart';

part 'create_presensi_pertemuan_params.dart';

class CreatePresensiPertemuan
    implements
        Usecase<Result<PresensiPertemuan>, CreatePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  CreatePresensiPertemuan({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      CreatePresensiPertemuanParams params) async {
    // Validasi role
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Akses ditolak: Hanya admin atau superAdmin yang dapat membuat presensi.');
    }

    // Validasi daftar hadir
    if (params.daftarHadir.isEmpty) {
      return const Result.failed('Daftar hadir tidak boleh kosong.');
    }

    try {
      // Generate summary dari daftar hadir
      final summary = _generateSummary(params.daftarHadir);

      // Buat objek presensi
      final presensiPertemuan = PresensiPertemuan(
        id: '', // ID akan di-generate oleh Firebase
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
        tanggal: params.tanggal,
        daftarHadir: params.daftarHadir,
        summary: summary,
        materi: params.materi,
        catatan: params.catatan,
      );

      // Simpan ke repository
      return await _presensiRepository
          .createPresensiPertemuan(presensiPertemuan);
    } catch (e) {
      return Result.failed('Gagal membuat presensi: ${e.toString()}');
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
      updatedAt: DateTime.now(),
    );
  }
}
