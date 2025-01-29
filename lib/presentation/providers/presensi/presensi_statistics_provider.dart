import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_statistics_data.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/presentation/providers/user_data/user_data_provider.dart';
import '../../../domain/usecase/presensi/get_presensi_statistics/get_presensi_statistics.dart';
import '../usecases/presensi/get_presensi_statistics_provider.dart';

part 'presensi_statistics_provider.g.dart';

@riverpod
class PresensiStatistics extends _$PresensiStatistics {
  @override
  Future<PresensiStatisticsData> build(String programId) async {
    // Ambil use case GetPresensiStatistics
    final getPresensiStatistics = ref.watch(getPresensiStatisticsProvider);
    // Ambil data user yang sedang login
    final user = ref.watch(userDataProvider).value;
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }
    // Panggil use case dengan parameter yang sesuai
    final result = await getPresensiStatistics(
      GetPresensiStatisticsParams(
        programId: programId,
        currentUserRole: user.role,
        startDate: null,
        endDate: null,
      ),
    );
    // Handle hasil dari use case
    return switch (result) {
      Success(value: final stats) => stats,
      Failed(:final message) => throw Exception(message),
    };
  }

  Future<void> refreshWithDateRange(
      DateTime startDate, DateTime endDate) async {
    state = const AsyncLoading();
    try {
      final getPresensiStatistics = ref.watch(getPresensiStatisticsProvider);
      final user = ref.watch(userDataProvider).value;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }
      final result = await getPresensiStatistics(
        GetPresensiStatisticsParams(
          programId: state.value!.programId,
          currentUserRole: user.role,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      state = switch (result) {
        Success(value: final stats) => AsyncData(stats),
        Failed(:final message) =>
          AsyncError(Exception(message), StackTrace.current),
      };
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
