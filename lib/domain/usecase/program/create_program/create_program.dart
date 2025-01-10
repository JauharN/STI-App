import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/program.dart';

part 'create_program_params.dart';

class CreateProgram implements Usecase<Result<Program>, CreateProgramParams> {
  final ProgramRepository _programRepository;

  CreateProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(CreateProgramParams params) async {
    // Validasi nama program
    final validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
    if (!validPrograms.contains(params.nama)) {
      return const Result.failed(
          'Invalid program name. Must be TAHFIDZ, GMM, or IFIS');
    }

    // Validasi jadwal tidak boleh kosong
    if (params.jadwal.isEmpty) {
      return const Result.failed('Program schedule cannot be empty');
    }

    // Buat objek Program
    final program = Program(
      id: '', // ID akan di-generate oleh Firebase
      nama: params.nama,
      deskripsi: params.deskripsi,
      jadwal: params.jadwal,
      lokasi: params.lokasi,
    );

    // Simpan ke repository
    return _programRepository.createProgram(program);
  }
}
