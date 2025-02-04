import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'delete_presensi_pertemuan_params.dart';

class DeletePresensiPertemuan
    implements Usecase<Result<void>, DeletePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  DeletePresensiPertemuan({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<void>> call(DeletePresensiPertemuanParams params) async {
    try {
      // Role validation
      if (!PresensiPertemuan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat menghapus presensi');
      }

      // Verify presensi exists
      final presensiResult = await _presensiRepository.getPresensiPertemuan(
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
      );

      if (presensiResult.isFailed) {
        return Result.failed(
            'Data presensi tidak ditemukan: ${presensiResult.errorMessage}');
      }

      // Delete from repository
      return await _presensiRepository.deletePresensiPertemuan(params.id);
    } catch (e) {
      return Result.failed('Gagal menghapus presensi: ${e.toString()}');
    }
  }
}
