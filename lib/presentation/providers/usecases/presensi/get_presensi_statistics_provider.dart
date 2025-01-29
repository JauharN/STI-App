import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/get_presensi_statistics/get_presensi_statistics.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_presensi_statistics_provider.g.dart';

@riverpod
GetPresensiStatistics getPresensiStatistics(GetPresensiStatisticsRef ref) =>
    GetPresensiStatistics(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
