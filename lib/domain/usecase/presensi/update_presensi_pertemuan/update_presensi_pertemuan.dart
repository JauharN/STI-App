import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import '../../usecase.dart';

part 'update_presensi_pertemuan_params.dart';

class UpdatePresensiPertemuan
    implements
        Usecase<Result<PresensiPertemuan>, UpdatePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  UpdatePresensiPertemuan({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      UpdatePresensiPertemuanParams params) async {
    try {
      // Role validation
      if (!PresensiPertemuan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat memperbarui presensi');
      }

      final presensiPertemuan = PresensiPertemuan(
        id: params.id,
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
        tanggal: params.tanggal,
        daftarHadir: params.daftarHadir,
        summary: params.summary,
        materi: params.materi,
        catatan: params.catatan,
        updatedAt: DateTime.now(),
        updatedBy: params.userId,
        createdAt: params.createdAt,
        createdBy: params.createdBy,
      );

      return await _presensiRepository
          .updatePresensiPertemuan(presensiPertemuan);
    } catch (e) {
      return Result.failed('Gagal memperbarui presensi: ${e.toString()}');
    }
  }
}
