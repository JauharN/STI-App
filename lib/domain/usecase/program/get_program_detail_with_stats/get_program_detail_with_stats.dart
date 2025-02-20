import 'package:flutter/material.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import '../../../entities/presensi/program_detail.dart';
import '../../usecase.dart';

part 'get_program_detail_with_stats_params.dart';

class GetProgramDetailWithStats
    implements
        Usecase<Result<(ProgramDetail, PresensiSummary)>,
            GetProgramDetailWithStatsParams> {
  final ProgramRepository _programRepository;

  GetProgramDetailWithStats({
    required ProgramRepository programRepository,
  }) : _programRepository = programRepository;

  @override
  Future<Result<(ProgramDetail, PresensiSummary)>> call(
      GetProgramDetailWithStatsParams params) async {
    try {
      if (!ProgramDetail.canView(params.currentUserRole)) {
        return const Result.failed(
            'Akses ditolak: Anda tidak memiliki akses untuk melihat detail program');
      }

      // Get program detail dan stats
      final result = await _programRepository.getProgramDetailWithStats(
        programId: params.programId,
        requestingUserId: params.requestingUserId,
      );

      if (result.isFailed) {
        debugPrint('Failed to get program details: ${result.errorMessage}');
        return Result.failed(result.errorMessage!);
      }

      final (programDetail, presensiSummary) = result.resultValue!;

      // Validasi data yang didapat
      if (!programDetail.isValid) {
        debugPrint('Invalid program detail data received');
        return const Result.failed('Data program tidak valid');
      }

      debugPrint(
          'Successfully retrieved program details for: ${params.programId}');
      return Result.success((programDetail, presensiSummary));
    } catch (e) {
      debugPrint('Error getting program details: $e');
      return Result.failed('Gagal mendapatkan detail program: ${e.toString()}');
    }
  }
}
