import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/result.dart';
import '../repositories/presensi_repository/presensi_repository_provider.dart';

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
      final repository = ref.read(presensiRepositoryProvider);
      final result = await repository.updatePresensiPertemuan(presensi);

      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Failed(e.toString());
    }
  }
}
