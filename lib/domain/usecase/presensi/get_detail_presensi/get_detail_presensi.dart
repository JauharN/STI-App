import 'package:sti_app/domain/entities/presensi/detail_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

import '../../usecase.dart';

part 'get_detail_presensi_params.dart';

class GetDetailPresensi
    implements Usecase<Result<DetailPresensi>, GetDetailPresensiParams> {
  final PresensiRepository _presensiRepository;

  GetDetailPresensi({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<DetailPresensi>> call(GetDetailPresensiParams params) async {
    try {
      return await _presensiRepository.getDetailPresensi(
        userId: params.userId,
        programId: params.programId,
        bulan: params.bulan,
        tahun: params.tahun,
      );
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
