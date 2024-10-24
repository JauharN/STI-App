import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/domain/usecase/sesi/delete_sesi/delete_sesi_params.dart';
import '../../../entities/result.dart';

class DeleteSesi implements Usecase<Result<void>, DeleteSesiParams> {
  final SesiRepository _sesiRepository;

  DeleteSesi({
    required SesiRepository sesiRepository,
  }) : _sesiRepository = sesiRepository;

  @override
  Future<Result<void>> call(DeleteSesiParams params) async {
    try {
      // Validasi ID
      if (params.sesiId.isEmpty) {
        return const Result.failed('ID sesi tidak valid');
      }

      // Hapus sesi
      return _sesiRepository.deleteSesi(params.sesiId);
    } catch (e) {
      return Result.failed('Gagal menghapus sesi: ${e.toString()}');
    }
  }
}
