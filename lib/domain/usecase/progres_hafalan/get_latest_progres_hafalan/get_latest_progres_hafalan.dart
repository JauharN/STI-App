import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'get_latest_progres_hafalan_params.dart';

class GetLatestProgresHafalan
    implements Usecase<Result<ProgresHafalan>, GetLatestProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  GetLatestProgresHafalan({
    required ProgresHafalanRepository progresHafalanRepository,
  }) : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(
      GetLatestProgresHafalanParams params) async {
    try {
      // Validate access for santri
      if (params.currentUserRole == 'santri' &&
          params.userId != params.requestingUserId) {
        return const Result.failed(
            'Santri hanya dapat melihat progres hafalannya sendiri');
      }

      // Get latest progres
      final result = await _progresHafalanRepository
          .getLatestProgresHafalan(params.userId);

      if (result.isFailed) {
        return Result.failed(
            'Gagal mengambil data progres hafalan: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
