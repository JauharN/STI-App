import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/domain/usecase/presensi/update_presensi/update_presensi_params.dart';
import '../../../entities/presensi.dart';
import '../../../entities/result.dart';

class UpdatePresensi
    implements Usecase<Result<Presensi>, UpdatePresensiParams> {
  final PresensiRepository _presensiRepository;

  UpdatePresensi({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<Presensi>> call(UpdatePresensiParams params) async {
    // Validasi status
    if (!['HADIR', 'IZIN', 'SAKIT', 'ALPHA'].contains(params.presensi.status)) {
      return const Result.failed('Invalid status');
    }

    return _presensiRepository.updatePresensi(params.presensi);
  }
}
