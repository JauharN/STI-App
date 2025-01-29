import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/program.dart';
import '../../../entities/user.dart';

part 'update_program_params.dart';

class UpdateProgram implements Usecase<Result<Program>, UpdateProgramParams> {
  final ProgramRepository _programRepository;

  UpdateProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(UpdateProgramParams params) async {
    // Validasi role pengguna
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Akses ditolak: Hanya admin atau superAdmin yang dapat memperbarui program.');
    }

    // Validasi ID program
    if (params.program.id.isEmpty) {
      return const Result.failed('Program ID cannot be empty');
    }

    // Validasi nama program
    if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(params.program.nama)) {
      return const Result.failed(
          'Invalid program name. Must be TAHFIDZ, GMM, or IFIS');
    }

    // Validasi jadwal tidak boleh kosong
    if (params.program.jadwal.isEmpty) {
      return const Result.failed('Program schedule cannot be empty');
    }

    // Validasi deskripsi tidak boleh kosong
    if (params.program.deskripsi.trim().isEmpty) {
      return const Result.failed('Program description cannot be empty');
    }

    // Update data program
    return _programRepository.updateProgram(params.program);
  }
}
