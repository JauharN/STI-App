import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_statistics_data.dart';
import 'package:sti_app/domain/entities/result.dart';

import '../repositories/presensi_repository/presensi_repository_provider.dart';

part 'presensi_statistics_provider.g.dart';

@riverpod
class PresensiStatistics extends _$PresensiStatistics {
  @override
  Future<PresensiStatisticsData> build(String programId) async {
    final result = await ref
        .watch(presensiRepositoryProvider)
        .getPresensiStatistics(
            programId: programId); // Tambahkan named parameter

    return switch (result) {
      Success(value: final stats) => stats,
      Failed(:final message) => throw Exception(message),
    };
  }

  // Optional: Tambahkan method untuk filter periode
  Future<void> refreshWithDateRange(
      DateTime startDate, DateTime endDate) async {
    state = const AsyncLoading();

    try {
      final result =
          await ref.read(presensiRepositoryProvider).getPresensiStatistics(
                programId: state.value!.programId,
                startDate: startDate,
                endDate: endDate,
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
