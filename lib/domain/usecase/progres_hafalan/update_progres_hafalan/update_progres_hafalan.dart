import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/update_progres_hafalan/update_progres_hafalan_params.dart';
import '../../../entities/result.dart';
import '../../../entities/progres_hafalan.dart';

class UpdateProgresHafalan
    implements Usecase<Result<ProgresHafalan>, UpdateProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  UpdateProgresHafalan(
      {required ProgresHafalanRepository progresHafalanRepository})
      : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(UpdateProgresHafalanParams params) async {
    // Validasi ID tidak boleh kosong
    if (params.progresHafalan.id.isEmpty) {
      return const Result.failed('Invalid progres hafalan ID');
    }

    // Validasi program ID
    if (!['TAHFIDZ', 'GMM'].contains(params.progresHafalan.programId)) {
      return const Result.failed('Invalid program ID');
    }

    // Validasi data berdasarkan jenis program
    if (params.progresHafalan.programId == 'TAHFIDZ') {
      // Validasi khusus program Tahfidz
      if (params.progresHafalan.juz == null ||
          params.progresHafalan.halaman == null ||
          params.progresHafalan.ayat == null) {
        return const Result.failed('Incomplete Tahfidz progress data');
      }
    } else {
      // Validasi khusus program GMM
      if (params.progresHafalan.iqroLevel == null ||
          params.progresHafalan.iqroHalaman == null ||
          params.progresHafalan.mutabaahTarget == null) {
        return const Result.failed('Incomplete GMM progress data');
      }
    }

    // Update data progres hafalan
    return _progresHafalanRepository
        .updateProgresHafalan(params.progresHafalan);
  }
}
