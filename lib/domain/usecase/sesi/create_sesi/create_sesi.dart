import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/usecase/sesi/create_sesi/create_sesi_params.dart';
import '../../../entities/result.dart';
import '../../../entities/sesi.dart';

class CreateSesi implements Usecase<Result<Sesi>, CreateSesiParams> {
  final SesiRepository _sesiRepository;
  final ProgramRepository _programRepository; // Untuk validasi program
  CreateSesi({
    required SesiRepository sesiRepository,
    required ProgramRepository programRepository,
  })  : _sesiRepository = sesiRepository,
        _programRepository = programRepository;
  @override
  Future<Result<Sesi>> call(CreateSesiParams params) async {
    try {
      // Validasi program exists
      final programResult =
          await _programRepository.getProgramById(params.programId);
      if (!programResult.isSuccess) {
        return const Result.failed('Program tidak ditemukan');
      }
      // Validasi waktu
      if (params.waktuMulai.isAfter(params.waktuSelesai)) {
        return const Result.failed(
            'Waktu mulai tidak boleh lebih dari waktu selesai');
      }
      // Validasi waktu tidak overlap dengan sesi lain
      final existingSesi =
          await _sesiRepository.getSesiByProgramId(params.programId);
      if (existingSesi.isSuccess) {
        for (var sesi in existingSesi.resultValue!) {
          if (_isOverlap(
            params.waktuMulai,
            params.waktuSelesai,
            sesi.waktuMulai,
            sesi.waktuSelesai,
          )) {
            return const Result.failed('Jadwal bertabrakan dengan sesi lain');
          }
        }
      }
      // Buat objek Sesi
      final sesi = Sesi(
        id: '', // ID akan di-generate oleh Firebase
        programId: params.programId,
        waktuMulai: params.waktuMulai,
        waktuSelesai: params.waktuSelesai,
        pengajarId: params.pengajarId,
        materi: params.materi,
        catatan: params.catatan,
      );
      // Simpan ke repository
      return _sesiRepository.createSesi(sesi);
    } catch (e) {
      return Result.failed('Gagal membuat sesi: ${e.toString()}');
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
