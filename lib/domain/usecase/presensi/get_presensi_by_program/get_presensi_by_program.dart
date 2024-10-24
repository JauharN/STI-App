import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/usecase/presensi/get_presensi_by_program/get_presensi_by_program_params.dart';
import '../../../entities/result.dart';
import '../../../entities/presensi.dart';

class GetPresensiByProgram
    implements Usecase<Result<List<Presensi>>, GetPresensiByProgramParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiByProgram({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<List<Presensi>>> call(GetPresensiByProgramParams params) async {
    // Validasi program ID
    if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(params.programId)) {
      return const Result.failed('Invalid program ID');
    }

    return _presensiRepository.getPresensiByProgramId(params.programId);
  }
}
