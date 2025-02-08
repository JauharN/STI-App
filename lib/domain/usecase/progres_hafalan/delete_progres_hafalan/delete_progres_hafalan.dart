import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'delete_progres_hafalan_params.dart';

class DeleteProgresHafalan
    implements Usecase<Result<void>, DeleteProgresHafalanParams> {
  final ProgresHafalanRepository _progresHafalanRepository;

  DeleteProgresHafalan({
    required ProgresHafalanRepository progresHafalanRepository,
  }) : _progresHafalanRepository = progresHafalanRepository;

  @override
  Future<Result<void>> call(DeleteProgresHafalanParams params) async {
    try {
      // Role validation
      if (!ProgresHafalan.canManage(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat menghapus progres hafalan');
      }

      // Verify progres exists
      final progresResult = await _progresHafalanRepository
          .getLatestProgresHafalan(params.userId);
      if (progresResult.isFailed) {
        return Result.failed(
            'Data progres hafalan tidak ditemukan: ${progresResult.errorMessage}');
      }

      // Delete from repository
      return await _progresHafalanRepository.deleteProgresHafalan(params.id);
    } catch (e) {
      return Result.failed('Gagal menghapus progres hafalan: ${e.toString()}');
    }
  }
}
