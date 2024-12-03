import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/usecase/presensi/get_presensi_summary/get_presensi_summary.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_presensi_summary_provider.g.dart';

@riverpod
GetPresensiSummary getPresensiSummary(GetPresensiSummaryRef ref) =>
    GetPresensiSummary(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
