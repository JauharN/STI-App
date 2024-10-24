import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/result.dart';
import '../../../entities/program.dart';

// Karena tidak memerlukan parameter, kita gunakan void
class GetAllPrograms implements Usecase<Result<List<Program>>, void> {
  final ProgramRepository _programRepository;

  GetAllPrograms({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<List<Program>>> call(void params) async {
    // Langsung mengambil semua program dari repository
    // Tidak perlu validasi karena tidak ada parameter yang perlu divalidasi
    return _programRepository.getAllPrograms();
  }
}
