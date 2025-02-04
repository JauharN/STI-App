import 'package:sti_app/domain/entities/presensi/presensi_statistics_data.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'get_presensi_statistics_params.dart';

class GetPresensiStatistics
    implements
        Usecase<Result<PresensiStatisticsData>, GetPresensiStatisticsParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiStatistics({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiStatisticsData>> call(
      GetPresensiStatisticsParams params) async {
    try {
      // Role validation
      if (!PresensiStatisticsData.canAccess(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat mengakses statistik');
      }

      // Date range validation
      if (params.startDate != null && params.endDate != null) {
        if (params.startDate!.isAfter(params.endDate!)) {
          return const Result.failed(
              'Tanggal awal tidak boleh setelah tanggal akhir');
        }
      }

      // Get statistics from repository
      return await _presensiRepository.getPresensiStatistics(
        programId: params.programId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    } catch (e) {
      return Result.failed(
          'Gagal mendapatkan statistik presensi: ${e.toString()}');
    }
  }
}
