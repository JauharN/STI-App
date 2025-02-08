import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/result.dart';
import '../repositories/presensi_repository/presensi_repository_provider.dart';

part 'recent_presensi_activities_provider.g.dart';

@riverpod
class RecentPresensiActivitiesController
    extends _$RecentPresensiActivitiesController {
  @override
  Future<List<PresensiPertemuan>> build(String programId) async {
    final repository = ref.watch(presensiRepositoryProvider);
    final result = await repository.getRecentPresensiPertemuan(
      programId: programId,
      limit: 5,
    );

    return switch (result) {
      Success(value: final activities) => activities,
      Failed(:final message) => throw Exception(message),
    };
  }

  // Method untuk refresh data
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(programId));
  }

  // Method untuk get statistics
  Map<String, int> getActivityStatistics(List<PresensiPertemuan> activities) {
    int totalHadir = 0;
    int totalSantri = 0;

    for (var activity in activities) {
      totalHadir += activity.summary.hadir;
      totalSantri += activity.summary.totalSantri;
    }

    return {
      'totalHadir': totalHadir,
      'totalSantri': totalSantri,
    };
  }
}
