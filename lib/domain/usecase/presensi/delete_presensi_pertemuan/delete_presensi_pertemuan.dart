import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../usecase.dart';

part 'delete_presensi_pertemuan_params.dart';

class DeletePresensiPertemuan
    implements Usecase<Result<void>, DeletePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  DeletePresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<void>> call(DeletePresensiPertemuanParams params) async {
    try {
      return await _presensiRepository.deletePresensiPertemuan(params.id);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
