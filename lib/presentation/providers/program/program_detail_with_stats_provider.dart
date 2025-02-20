import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/usecase/program/get_program_detail_with_stats/get_program_detail_with_stats.dart';
import '../../../domain/entities/presensi/program_detail.dart';
import '../user_data/user_data_provider.dart';
import '../usecases/program/get_program_detail_with_stats_provider.dart';

part 'program_detail_with_stats_provider.g.dart';

@riverpod
class ProgramDetailWithStatsState extends _$ProgramDetailWithStatsState {
  @override
  Future<(ProgramDetail, PresensiSummary)> build(String programId) async {
    final getProgramDetailWithStats =
        ref.watch(getProgramDetailWithStatsProvider);
    final user = ref.watch(userDataProvider).value;

    if (user == null) throw Exception('User tidak ditemukan');

    final result = await getProgramDetailWithStats(
      GetProgramDetailWithStatsParams(
        programId: programId,
        requestingUserId: user.uid,
        currentUserRole: user.role,
      ),
    );

    return switch (result) {
      Success(value: final data) => data,
      Failed(:final message) => throw Exception(message),
    };
  }

  // Handle refresh untuk update data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  // State management untuk loading dan error states
  bool get isLoading => state.isLoading;

  AsyncValue<(ProgramDetail, PresensiSummary)> get currentState => state;
}
