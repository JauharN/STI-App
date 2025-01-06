import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/presensi/santri_presensi.dart';
import '../../domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../../domain/usecase/presensi/delete_presensi_pertemuan/delete_presensi_pertemuan.dart';
import '../../domain/usecase/presensi/get_all_presensi_pertemuan/get_all_presensi_pertemuan.dart';
import '../../domain/usecase/presensi/update_presensi_pertemuan/update_presensi_pertemuan.dart';
import '../states/presensi_state.dart';

class ManagePresensiViewModel extends StateNotifier<PresensiState> {
  final CreatePresensiPertemuan createPresensi;
  final GetAllPresensiPertemuan getAllPresensi;
  final UpdatePresensiPertemuan updatePresensi;
  final DeletePresensiPertemuan deletePresensi;

  ManagePresensiViewModel({
    required this.createPresensi,
    required this.getAllPresensi,
    required this.updatePresensi,
    required this.deletePresensi,
  }) : super(const PresensiState.initial());

  // Method untuk mengambil semua presensi
  Future<void> fetchAllPresensi(String programId) async {
    state = const PresensiState.loading();
    final result = await getAllPresensi(
        GetAllPresensiPertemuanParams(programId: programId));

    if (result.isSuccess) {
      state = PresensiState.loaded(result.resultValue!);
    } else {
      state =
          PresensiState.error(result.errorMessage ?? 'Error fetching presensi');
    }
  }

  // Method untuk menambahkan presensi baru
  Future<void> addPresensi({
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required List<SantriPresensi> daftarHadir,
    required PresensiSummary summary,
    String? materi,
    String? catatan,
  }) async {
    state = const PresensiState.loading();

    final params = CreatePresensiPertemuanParams(
      programId: programId,
      pertemuanKe: pertemuanKe,
      tanggal: tanggal,
      daftarHadir: daftarHadir,
      materi: materi,
      catatan: catatan,
      summary: summary,
    );

    final result = await createPresensi(params);

    if (result.isSuccess) {
      fetchAllPresensi(programId);
    } else {
      state =
          PresensiState.error(result.errorMessage ?? 'Error adding presensi');
    }
  }

  // Method untuk memperbarui presensi
  Future<void> updateExistingPresensi({
    required String id,
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required List<SantriPresensi> daftarHadir,
    required PresensiSummary summary,
    String? materi,
    String? catatan,
  }) async {
    state = const PresensiState.loading();

    final params = UpdatePresensiPertemuanParams(
      id: id,
      programId: programId,
      pertemuanKe: pertemuanKe,
      tanggal: tanggal,
      daftarHadir: daftarHadir,
      summary: summary,
      materi: materi,
      catatan: catatan,
    );

    final result = await updatePresensi(params);

    if (result.isSuccess) {
      fetchAllPresensi(programId);
    } else {
      state =
          PresensiState.error(result.errorMessage ?? 'Error updating presensi');
    }
  }

  // Method untuk menghapus presensi
  Future<void> deletePresensiById(String id, String programId) async {
    state = const PresensiState.loading();

    final params = DeletePresensiPertemuanParams(id: id);

    final result = await deletePresensi(params);

    if (result.isSuccess) {
      fetchAllPresensi(programId);
    } else {
      state =
          PresensiState.error(result.errorMessage ?? 'Error deleting presensi');
    }
  }
}
