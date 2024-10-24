import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/create_progres_hafalan/create_progres_hafalan_params.dart';
import '../../../entities/result.dart';
import '../../../entities/progres_hafalan.dart';

class CreateProgresHafalan
    implements Usecase<Result<ProgresHafalan>, CreateProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  CreateProgresHafalan(
      {required ProgresHafalanRepository progresHafalanRepository})
      : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(CreateProgresHafalanParams params) async {
    // Validasi program ID
    if (!['TAHFIDZ', 'GMM'].contains(params.programId)) {
      return const Result.failed('Invalid program ID');
    }

    // Validasi data berdasarkan jenis program
    if (params.programId == 'TAHFIDZ') {
      // Validasi field khusus Tahfidz
      if (params.juz == null || params.halaman == null || params.ayat == null) {
        return const Result.failed('Incomplete Tahfidz progress data');
      }
    } else {
      // Validasi field khusus GMM
      if (params.iqroLevel == null ||
          params.iqroHalaman == null ||
          params.mutabaahTarget == null) {
        return const Result.failed('Incomplete GMM progress data');
      }
    }

    // Buat objek ProgresHafalan
    final progresHafalan = ProgresHafalan(
      id: '', // ID akan di-generate oleh Firebase
      userId: params.userId,
      programId: params.programId,
      tanggal: params.tanggal,
      // Field Tahfidz
      juz: params.juz,
      halaman: params.halaman,
      ayat: params.ayat,
      // Field GMM
      iqroLevel: params.iqroLevel,
      iqroHalaman: params.iqroHalaman,
      mutabaahTarget: params.mutabaahTarget,
      catatan: params.catatan,
    );

    // Simpan ke repository
    return _progresHafalanRepository.createProgresHafalan(progresHafalan);
  }
}
