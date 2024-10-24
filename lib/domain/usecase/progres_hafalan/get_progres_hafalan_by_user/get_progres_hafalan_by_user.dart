import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/get_progres_hafalan_by_user/get_progres_hafalan_by_user_params.dart';
import '../../../entities/result.dart';
import '../../../entities/progres_hafalan.dart';

class GetProgresHafalanByUser
    implements
        Usecase<Result<List<ProgresHafalan>>, GetProgresHafalanByUserParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  GetProgresHafalanByUser(
      {required ProgresHafalanRepository progresHafalanRepository})
      : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<List<ProgresHafalan>>> call(
      GetProgresHafalanByUserParams params) async {
    // Validasi user ID
    if (params.userId.isEmpty) {
      return const Result.failed('Invalid user ID');
    }

    // Ambil semua riwayat progres hafalan santri
    return _progresHafalanRepository.getProgresHafalanByUserId(params.userId);
  }
}
