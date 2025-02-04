import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/get_program_detail_with_stats/get_program_detail_with_stats.dart';
import '../../repositories/program_repository/program_repository_provider.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_program_detail_with_stats_provider.g.dart';

@riverpod
GetProgramDetailWithStats getProgramDetailWithStats(
    GetProgramDetailWithStatsRef ref) {
  return GetProgramDetailWithStats(
    programRepository: ref.watch(programRepositoryProvider),
    presensiRepository: ref.watch(presensiRepositoryProvider),
  );
}
