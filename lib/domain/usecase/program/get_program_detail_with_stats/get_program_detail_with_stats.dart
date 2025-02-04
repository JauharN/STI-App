import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../../entities/presensi/program_detail.dart';
import '../../usecase.dart';

part 'get_program_detail_with_stats_params.dart';

class GetProgramDetailWithStats
    implements
        Usecase<Result<(ProgramDetail, PresensiSummary)>,
            GetProgramDetailWithStatsParams> {
  final ProgramRepository _programRepository;
  final PresensiRepository _presensiRepository;

  GetProgramDetailWithStats({
    required ProgramRepository programRepository,
    required PresensiRepository presensiRepository,
  })  : _programRepository = programRepository,
        _presensiRepository = presensiRepository;

  @override
  Future<Result<(ProgramDetail, PresensiSummary)>> call(
      GetProgramDetailWithStatsParams params) async {
    try {
      // Role validation
      if (!ProgramDetail.canView(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Anda tidak memiliki akses untuk melihat detail program');
      }

      // Get program detail
      final programResult =
          await _programRepository.getProgramById(params.programId);

      if (programResult.isFailed) {
        return Result.failed(programResult.errorMessage!);
      }

      // Convert Program to ProgramDetail
      final program = programResult.resultValue!;
      final programDetail = ProgramDetail(
        id: program.id,
        name: program.nama,
        description: program.deskripsi,
        schedule: program.jadwal,
        totalMeetings: program.totalPertemuan ?? 0,
        location: program.lokasi,
        teacherId: program.pengajarId,
        teacherName: program.pengajarName,
        enrolledSantriIds: [], // Will be populated from user repository if needed
        createdAt: program.createdAt,
        updatedAt: program.updatedAt,
      );

      // Get presensi summary
      final summaryResult = await _presensiRepository.getPresensiSummary(
        userId: params.requestingUserId,
        programId: params.programId,
      );

      if (summaryResult.isFailed) {
        return Result.failed(summaryResult.errorMessage!);
      }

      return Result.success((programDetail, summaryResult.resultValue!));
    } catch (e) {
      return Result.failed('Gagal mendapatkan detail program: ${e.toString()}');
    }
  }
}
