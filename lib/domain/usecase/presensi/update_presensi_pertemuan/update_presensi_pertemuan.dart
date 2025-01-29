import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../../entities/presensi/presensi_summary.dart';
import '../../../entities/presensi/santri_presensi.dart';
import '../../../entities/user.dart';
import '../../usecase.dart';

part 'update_presensi_pertemuan_params.dart';

class UpdatePresensiPertemuan
    implements
        Usecase<Result<PresensiPertemuan>, UpdatePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  UpdatePresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      UpdatePresensiPertemuanParams params) async {
    // Validasi role
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Akses ditolak: Hanya admin atau superAdmin yang dapat memperbarui presensi.');
    }

    try {
      final presensiPertemuan = PresensiPertemuan(
        id: params.id,
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
        tanggal: params.tanggal,
        daftarHadir: params.daftarHadir,
        summary: params.summary,
        materi: params.materi,
        catatan: params.catatan,
      );

      return await _presensiRepository
          .updatePresensiPertemuan(presensiPertemuan);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
