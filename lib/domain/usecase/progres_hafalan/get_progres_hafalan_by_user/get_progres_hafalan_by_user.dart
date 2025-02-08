import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'get_progres_hafalan_by_user_params.dart';

class GetProgresHafalanByUser
    implements
        Usecase<Result<List<ProgresHafalan>>, GetProgresHafalanByUserParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  GetProgresHafalanByUser({
    required ProgresHafalanRepository progresHafalanRepository,
  }) : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<List<ProgresHafalan>>> call(
      GetProgresHafalanByUserParams params) async {
    try {
      // Validate access for santri
      if (params.currentUserRole == 'santri' &&
          params.userId != params.requestingUserId) {
        return const Result.failed(
            'Santri hanya dapat melihat riwayat progres hafalannya sendiri');
      }

      // Get progres list
      final result = await _progresHafalanRepository
          .getProgresHafalanByUserId(params.userId);

      if (result.isFailed) {
        return Result.failed(
            'Gagal mengambil riwayat progres hafalan: ${result.errorMessage}');
      }

      final progresList = result.resultValue!;

      // Filter by date range if specified
      if (params.startDate != null && params.endDate != null) {
        return Result.success(progresList
            .where((progres) =>
                progres.tanggal.isAfter(params.startDate!) &&
                progres.tanggal
                    .isBefore(params.endDate!.add(const Duration(days: 1))))
            .toList());
      }

      // Filter by program if specified
      if (params.programId != null) {
        return Result.success(progresList
            .where((progres) => progres.programId == params.programId)
            .toList());
      }

      return result;
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
