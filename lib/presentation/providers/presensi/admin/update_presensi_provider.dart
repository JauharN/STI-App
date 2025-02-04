import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../../domain/entities/result.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';
import '../../user_data/user_data_provider.dart';

part 'update_presensi_provider.g.dart';

@riverpod
class UpdatePresensi extends _$UpdatePresensi {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<Result<void>> updatePresensi({
    required String programId,
    required PresensiPertemuan presensi,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = ref.read(userDataProvider).value;
      if (user == null) {
        return const Result.failed('User tidak ditemukan');
      }

      // Role validation
      if (user.role != 'admin' && user.role != 'superAdmin') {
        return const Result.failed(
            'Hanya admin yang dapat mengupdate presensi');
      }

      final repository = ref.read(presensiRepositoryProvider);

      // Add updater info
      final updatedPresensi =
          presensi.copyWith(updatedAt: DateTime.now(), updatedBy: user.uid);

      final result = await repository.updatePresensiPertemuan(updatedPresensi);

      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Result.failed(e.toString());
    }
  }
}
