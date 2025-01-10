import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/sesi.dart';

part 'get_sesi_by_program_params.dart';

class GetSesiByProgram
    implements Usecase<Result<List<Sesi>>, GetSesiByProgramParams> {
  final SesiRepository _sesiRepository;
  final ProgramRepository _programRepository; // Untuk validasi program

  GetSesiByProgram({
    required SesiRepository sesiRepository,
    required ProgramRepository programRepository,
  })  : _sesiRepository = sesiRepository,
        _programRepository = programRepository;

  @override
  Future<Result<List<Sesi>>> call(GetSesiByProgramParams params) async {
    try {
      // Validasi program ID
      if (params.programId.isEmpty) {
        return const Result.failed('ID program tidak valid');
      }

      // Validasi program exists
      final programResult = await _programRepository.getProgramById(
        params.programId,
      );
      if (!programResult.isSuccess) {
        return const Result.failed('Program tidak ditemukan');
      }

      // Ambil semua sesi untuk program ini
      final result = await _sesiRepository.getSesiByProgramId(params.programId);

      if (result.isSuccess) {
        // Sort sesi berdasarkan waktu (terbaru di atas)
        final sesiList = result.resultValue!;
        sesiList.sort((a, b) => b.waktuMulai.compareTo(a.waktuMulai));
        return Result.success(sesiList);
      }

      return result;
    } catch (e) {
      return Result.failed('Gagal mengambil data sesi: ${e.toString()}');
    }
  }
}
