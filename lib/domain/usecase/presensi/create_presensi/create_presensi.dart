import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import '../../../entities/presensi.dart';
import '../../../entities/result.dart';

part 'create_presensi_params.dart';

class CreatePresensi
    implements Usecase<Result<Presensi>, CreatePresensiParams> {
  final PresensiRepository _presensiRepository;

  CreatePresensi({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<Presensi>> call(CreatePresensiParams params) async {
    final presensi = Presensi(
      id: '', // akan digenerate oleh Firebase
      userId: params.userId,
      programId: params.programId,
      tanggal: params.tanggal,
      status: params.status,
      keterangan: params.keterangan,
    );

    return _presensiRepository.createPresensi(presensi);
  }
}
