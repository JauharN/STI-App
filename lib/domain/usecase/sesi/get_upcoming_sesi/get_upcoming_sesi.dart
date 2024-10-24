import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/usecase/sesi/get_upcoming_sesi/get_upcoming_sesi_params.dart';
import '../../../entities/result.dart';
import '../../../entities/sesi.dart';

class GetUpcomingSesi
    implements Usecase<Result<List<Sesi>>, GetUpcomingSesiParams> {
  final SesiRepository _sesiRepository;
  final ProgramRepository _programRepository; // Untuk validasi program

  GetUpcomingSesi({
    required SesiRepository sesiRepository,
    required ProgramRepository programRepository,
  })  : _sesiRepository = sesiRepository,
        _programRepository = programRepository;

  @override
  Future<Result<List<Sesi>>> call(GetUpcomingSesiParams params) async {
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

      // Ambil sesi yang akan datang
      final result = await _sesiRepository.getUpcomingSesi(params.programId);

      if (result.isSuccess) {
        var sesiList = result.resultValue!;

        // Sort berdasarkan waktu terdekat
        sesiList.sort((a, b) => a.waktuMulai.compareTo(b.waktuMulai));

        // Batasi jumlah sesi jika ada limit
        if (params.limit != null && params.limit! > 0) {
          sesiList = sesiList.take(params.limit!).toList();
        }

        return Result.success(sesiList);
      }

      return result;
    } catch (e) {
      return Result.failed(
          'Gagal mengambil data sesi mendatang: ${e.toString()}');
    }
  }
}
