import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'get_presensi_pertemuan_params.dart';

class GetPresensiPertemuan
    implements Usecase<Result<PresensiPertemuan>, GetPresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiPertemuan({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      GetPresensiPertemuanParams params) async {
    try {
      // Validasi role
      if (!PresensiPertemuan.canView(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Anda tidak memiliki akses untuk melihat presensi');
      }

      // Get presensi from repository
      final result = await _presensiRepository.getPresensiPertemuan(
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
      );

      if (result.isFailed) {
        return Result.failed(
            'Gagal mendapatkan data presensi: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
