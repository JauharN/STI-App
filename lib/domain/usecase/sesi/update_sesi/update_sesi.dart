import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/sesi.dart';

part 'update_sesi_params.dart';

class UpdateSesi implements Usecase<Result<Sesi>, UpdateSesiParams> {
  final SesiRepository _sesiRepository;
  final ProgramRepository _programRepository; // Untuk validasi program

  UpdateSesi({
    required SesiRepository sesiRepository,
    required ProgramRepository programRepository,
  })  : _sesiRepository = sesiRepository,
        _programRepository = programRepository;

  @override
  Future<Result<Sesi>> call(UpdateSesiParams params) async {
    try {
      // Validasi ID sesi
      if (params.sesi.id.isEmpty) {
        return const Result.failed('ID sesi tidak valid');
      }

      // Validasi program exists
      final programResult = await _programRepository.getProgramById(
        params.sesi.programId,
      );
      if (!programResult.isSuccess) {
        return const Result.failed('Program tidak ditemukan');
      }

      // Validasi waktu
      if (params.sesi.waktuMulai.isAfter(params.sesi.waktuSelesai)) {
        return const Result.failed(
            'Waktu mulai tidak boleh lebih dari waktu selesai');
      }

      // Validasi waktu tidak overlap dengan sesi lain
      final existingSesi = await _sesiRepository.getSesiByProgramId(
        params.sesi.programId,
      );
      if (existingSesi.isSuccess) {
        for (var sesi in existingSesi.resultValue!) {
          // Skip pengecekan dengan sesi yang sedang diupdate
          if (sesi.id == params.sesi.id) continue;

          if (_isOverlap(
            params.sesi.waktuMulai,
            params.sesi.waktuSelesai,
            sesi.waktuMulai,
            sesi.waktuSelesai,
          )) {
            return const Result.failed('Jadwal bertabrakan dengan sesi lain');
          }
        }
      }

      // Update sesi
      return _sesiRepository.updateSesi(params.sesi);
    } catch (e) {
      return Result.failed('Gagal mengupdate sesi: ${e.toString()}');
    }
  }

  // Helper untuk cek overlap waktu
  bool _isOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
}
