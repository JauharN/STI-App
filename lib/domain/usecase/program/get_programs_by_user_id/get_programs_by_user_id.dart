import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'get_programs_by_user_id_params.dart';

class GetProgramsByUserId
    implements Usecase<Result<List<Program>>, GetProgramsByUserIdParams> {
  final ProgramRepository _programRepository;

  GetProgramsByUserId({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<List<Program>>> call(GetProgramsByUserIdParams params) async {
    try {
      if (params.userId.isEmpty) {
        return const Result.failed('ID User tidak boleh kosong');
      }

      // Santri hanya bisa lihat programnya sendiri
      if (params.currentUserRole == 'santri' &&
          params.userId != params.requestingUserId) {
        return const Result.failed(
            'Anda hanya dapat melihat program yang Anda ikuti');
      }

      final result =
          await _programRepository.getProgramsByUserId(params.userId);

      // Filter program aktif untuk santri
      if (params.currentUserRole == 'santri' && result.isSuccess) {
        final programs = result.resultValue!
            .where((program) =>
                program.totalPertemuan != null && program.totalPertemuan! > 0)
            .toList();

        return Result.success(programs);
      }

      return result;
    } catch (e) {
      return Result.failed('Gagal mengambil daftar program: ${e.toString()}');
    }
  }
}
