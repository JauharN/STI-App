import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'create_progres_hafalan_params.dart';

class CreateProgresHafalan
    implements Usecase<Result<ProgresHafalan>, CreateProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  CreateProgresHafalan({
    required ProgresHafalanRepository progresHafalanRepository,
  }) : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<ProgresHafalan>> call(CreateProgresHafalanParams params) async {
    try {
      // Role validation
      if (!ProgresHafalan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat membuat progres hafalan');
      }

      // Validasi program
      if (!['TAHFIDZ', 'GMM'].contains(params.programId)) {
        return const Result.failed('Program ID tidak valid');
      }

      // Create progres object
      final progresHafalan = ProgresHafalan(
        id: '', // Will be generated by Firebase
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: params.userId,
        updatedBy: params.userId,
      );

      // Save to repository
      return _progresHafalanRepository.createProgresHafalan(progresHafalan);
    } catch (e) {
      return Result.failed('Gagal membuat progres hafalan: ${e.toString()}');
    }
  }
}
