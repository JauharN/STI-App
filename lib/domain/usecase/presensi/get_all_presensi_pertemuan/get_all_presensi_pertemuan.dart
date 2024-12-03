import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../usecase.dart';

part 'get_all_presensi_pertemuan_params.dart';

class GetAllPresensiPertemuan
    implements
        Usecase<Result<List<PresensiPertemuan>>,
            GetAllPresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  GetAllPresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<List<PresensiPertemuan>>> call(
      GetAllPresensiPertemuanParams params) async {
    try {
      return await _presensiRepository
          .getAllPresensiPertemuan(params.programId);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
