import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'create_program_params.dart';

class CreateProgram implements Usecase<Result<Program>, CreateProgramParams> {
  final ProgramRepository _programRepository;

  CreateProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(CreateProgramParams params) async {
    try {
      // Validasi role
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat membuat program');
      }

      // Validasi nama program
      final validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
      if (!validPrograms.contains(params.nama.toUpperCase())) {
        return const Result.failed(
            'Nama program harus TAHFIDZ, GMM, atau IFIS');
      }

      // Validasi jadwal
      if (params.jadwal.isEmpty) {
        return const Result.failed('Jadwal program tidak boleh kosong');
      }

      // Create program object
      final program = Program(
        id: '', // Will be generated by Firebase
        nama: params.nama.toUpperCase(),
        deskripsi: params.deskripsi,
        jadwal: params.jadwal,
        lokasi: params.lokasi,
        pengajarId: params.pengajarId,
        pengajarName: params.pengajarName,
        kelas: params.kelas,
        totalPertemuan: params.totalPertemuan,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to repository
      return _programRepository.createProgram(program);
    } catch (e) {
      return Result.failed('Gagal membuat program: ${e.toString()}');
    }
  }
}
