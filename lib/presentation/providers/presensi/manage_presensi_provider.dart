import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/usecase/presensi/delete_presensi_pertemuan/delete_presensi_pertemuan.dart';
import '../../../domain/usecase/presensi/get_all_presensi_pertemuan/get_all_presensi_pertemuan.dart';
import '../usecases/presensi/delete_presensi_pertemuan_provider.dart';
import '../usecases/presensi/get_all_presensi_pertemuan_provider.dart';

part 'manage_presensi_provider.g.dart';

@riverpod
class ManagePresensiState extends _$ManagePresensiState {
  @override
  Future<List<PresensiPertemuan>> build(String programId) async {
    // Get presensi pertemuan list
    final getAllPresensi = ref.read(getAllPresensiPertemuanProvider);

    final result = await getAllPresensi(
        GetAllPresensiPertemuanParams(programId: programId));

    return switch (result) {
      Success(value: final presensi) => presensi,
      Failed(:final message) => throw Exception(message),
    };
  }

  // Method untuk hapus presensi
  Future<void> deletePresensi(String presensiId) async {
    state = const AsyncLoading();

    final deletePresensi = ref.read(deletePresensiPertemuanProvider);
    final result =
        await deletePresensi(DeletePresensiPertemuanParams(id: presensiId));

    // Refresh list setelah hapus
    if (result case Success()) {
      ref.invalidateSelf();
    }
  }
}
