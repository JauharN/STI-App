import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../../domain/entities/result.dart';
import '../../../../domain/usecase/presensi/delete_presensi_pertemuan/delete_presensi_pertemuan.dart';
import '../../../../domain/usecase/presensi/get_all_presensi_pertemuan/get_all_presensi_pertemuan.dart';
import '../../usecases/presensi/delete_presensi_pertemuan_provider.dart';
import '../../usecases/presensi/get_all_presensi_pertemuan_provider.dart';
import '../../user_data/user_data_provider.dart';

part 'manage_presensi_provider.g.dart';

@riverpod
class ManagePresensiState extends _$ManagePresensiState {
  @override
  Future<List<PresensiPertemuan>> build(String programId) async {
    final getAllPresensi = ref.read(getAllPresensiPertemuanProvider);

    // Get current user role
    final user = ref.read(userDataProvider).value;
    if (user == null) throw Exception('User tidak ditemukan');

    final result = await getAllPresensi(GetAllPresensiPertemuanParams(
      programId: programId,
      currentUserRole: user.role, // String role
    ));

    return switch (result) {
      Success(value: final presensi) => presensi,
      Failed(:final message) => throw Exception(message),
    };
  }

  Future<void> deletePresensi(String presensiId) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(userDataProvider).value;
      if (user == null) throw Exception('User tidak ditemukan');

      final deletePresensi = ref.read(deletePresensiPertemuanProvider);
      final result = await deletePresensi(
        DeletePresensiPertemuanParams(
          id: presensiId,
          programId: state.value?.first.programId ?? '',
          pertemuanKe: state.value?.first.pertemuanKe ?? 0,
          currentUserRole: user.role, // String role
        ),
      );

      if (result is Success) {
        ref.invalidateSelf();
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
