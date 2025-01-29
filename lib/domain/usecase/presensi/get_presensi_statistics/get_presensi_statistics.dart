import 'package:sti_app/domain/entities/presensi/presensi_statistics_data.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../../entities/user.dart';
import '../../usecase.dart';

part 'get_presensi_statistics_params.dart';

class GetPresensiStatistics
    implements
        Usecase<Result<PresensiStatisticsData>, GetPresensiStatisticsParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiStatistics({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiStatisticsData>> call(
      GetPresensiStatisticsParams params) async {
    // Validasi role pengguna
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Akses ditolak: Hanya admin atau superAdmin yang dapat mengakses statistik.');
    }

    // Panggil data layer untuk mendapatkan statistik
    return await _presensiRepository.getPresensiStatistics(
      programId: params.programId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
