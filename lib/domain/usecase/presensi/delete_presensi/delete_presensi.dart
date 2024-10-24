import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/usecase/presensi/delete_presensi/delete_presensi_params.dart';
import '../../../entities/result.dart';

class DeletePresensi implements Usecase<Result<void>, DeletePresensiParams> {
  final PresensiRepository _presensiRepository;

  DeletePresensi({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<void>> call(DeletePresensiParams params) async {
    if (params.presensiId.isEmpty) {
      return const Result.failed('Invalid presensi ID');
    }

    return _presensiRepository.deletePresensi(params.presensiId);
  }
}
