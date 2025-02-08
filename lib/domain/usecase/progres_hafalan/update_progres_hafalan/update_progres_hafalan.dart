import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'update_progres_hafalan_params.dart';

class UpdateProgresHafalan
    implements Usecase<Result<ProgresHafalan>, UpdateProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  UpdateProgresHafalan({
    required ProgresHafalanRepository progresHafalanRepository,
  }) : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(UpdateProgresHafalanParams params) async {
    try {
      // Role validation
      if (!ProgresHafalan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat memperbarui progres hafalan');
      }

      // Create updated progres object
      final updatedProgres = ProgresHafalan(
        id: params.id,
        userId: params.userId,
        programId: params.programId,
        tanggal: params.tanggal,
        // Tahfidz fields
        juz: params.juz,
        halaman: params.halaman,
        ayat: params.ayat,
        surah: params.surah,
        statusPenilaian: params.statusPenilaian,
        // GMM fields
        iqroLevel: params.iqroLevel,
        iqroHalaman: params.iqroHalaman,
        statusIqro: params.statusIqro,
        mutabaahTarget: params.mutabaahTarget,
        statusMutabaah: params.statusMutabaah,
        // Common fields
        catatan: params.catatan,
        updatedAt: DateTime.now(),
        updatedBy: params.userId,
        createdAt: params.createdAt,
        createdBy: params.createdBy,
      );

      // Update in repository
      return await _progresHafalanRepository
          .updateProgresHafalan(updatedProgres);
    } catch (e) {
      return Result.failed(
          'Gagal memperbarui progres hafalan: ${e.toString()}');
    }
  }
}
