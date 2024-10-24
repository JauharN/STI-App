import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/get_latest_progres_hafalan/get_latest_progres_hafalan_params.dart';
import '../../../entities/result.dart';
import '../../../entities/progres_hafalan.dart';

class GetLatestProgresHafalan
    implements Usecase<Result<ProgresHafalan>, GetLatestProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  GetLatestProgresHafalan(
      {required ProgresHafalanRepository progresHafalanRepository})
      : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(
      GetLatestProgresHafalanParams params) async {
    // Validasi user ID
    if (params.userId.isEmpty) {
      return const Result.failed('Invalid user ID');
    }

    // Ambil progres hafalan terbaru
    return _progresHafalanRepository.getLatestProgresHafalan(params.userId);
  }
}
