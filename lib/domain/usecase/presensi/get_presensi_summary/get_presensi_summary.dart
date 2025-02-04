import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'get_presensi_summary_params.dart';

class GetPresensiSummary
    implements Usecase<Result<PresensiSummary>, GetPresensiSummaryParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiSummary({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiSummary>> call(GetPresensiSummaryParams params) async {
    try {
      // Validate access for santri
      if (params.currentUserRole == 'santri' &&
          params.userId != params.requestingUserId) {
        return const Result.failed(
            'Santri hanya dapat melihat ringkasan presensi mereka sendiri');
      }

      return await _presensiRepository.getPresensiSummary(
        userId: params.userId,
        programId: params.programId,
      );
    } catch (e) {
      return Result.failed(
          'Gagal mengambil ringkasan presensi: ${e.toString()}');
    }
  }
}
