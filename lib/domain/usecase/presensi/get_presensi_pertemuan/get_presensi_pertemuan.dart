import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'get_presensi_pertemuan_params.dart';

class GetPresensiPertemuan
    implements Usecase<Result<PresensiPertemuan>, GetPresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<PresensiPertemuan>> call(
      GetPresensiPertemuanParams params) async {
    try {
      return await _presensiRepository.getPresensiPertemuan(
        programId: params.programId,
        pertemuanKe: params.pertemuanKe,
      );
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
