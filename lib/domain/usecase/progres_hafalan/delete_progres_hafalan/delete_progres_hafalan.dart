import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import '../../../entities/result.dart';

part 'delete_progres_hafalan_params.dart';

class DeleteProgresHafalan
    implements Usecase<Result<void>, DeleteProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  DeleteProgresHafalan(
      {required ProgresHafalanRepository progresHafalanRepository})
      : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<void>> call(DeleteProgresHafalanParams params) async {
    // Validasi ID tidak boleh kosong
    if (params.progresHafalanId.isEmpty) {
      return const Result.failed('Invalid progres hafalan ID');
    }

    // Hapus data progres hafalan
    return _progresHafalanRepository
        .deleteProgresHafalan(params.progresHafalanId);
  }
}
