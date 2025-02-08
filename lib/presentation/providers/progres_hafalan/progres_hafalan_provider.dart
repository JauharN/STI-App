import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/progres_hafalan.dart';
import '../../../domain/entities/result.dart';
import '../usecases/progres_hafalan/create_progres_hafalan_provider.dart';
import '../usecases/progres_hafalan/delete_progres_hafalan_provider.dart';
import '../usecases/progres_hafalan/get_progres_hafalan_by_user_provider.dart';
import '../usecases/progres_hafalan/update_progres_hafalan_provider.dart';
import '../../../domain/usecase/progres_hafalan/create_progres_hafalan/create_progres_hafalan.dart';
import '../../../domain/usecase/progres_hafalan/delete_progres_hafalan/delete_progres_hafalan.dart';
import '../../../domain/usecase/progres_hafalan/get_progres_hafalan_by_user/get_progres_hafalan_by_user.dart';
import '../../../domain/usecase/progres_hafalan/update_progres_hafalan/update_progres_hafalan.dart';

import '../user_data/user_data_provider.dart';

part 'progres_hafalan_provider.g.dart';

@riverpod
class ProgresHafalanNotifier extends _$ProgresHafalanNotifier {
  @override
  AsyncValue<List<ProgresHafalan>> build() {
    return const AsyncValue.data([]);
  }

  // Get List Progres
  Future<void> getProgresHafalan(String userId) async {
    try {
      state = const AsyncValue.loading();

      final currentUser = ref.read(userDataProvider).value;
      if (currentUser == null) {
        state = const AsyncValue.error(
          'User data tidak ditemukan',
          StackTrace.empty,
        );
        return;
      }

      final result = await ref.read(getProgresHafalanByUserProvider).call(
            GetProgresHafalanByUserParams(
              userId: userId,
              requestingUserId: currentUser.uid,
              currentUserRole: currentUser.role,
            ),
          );

      switch (result) {
        case Success(value: final progresList):
          state = AsyncValue.data(progresList);
        case Failed(message: final message):
          state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Create Progres
  Future<void> createProgres({
    required String userId,
    required String programId,
    required DateTime tanggal,
    // Tahfidz
    int? juz,
    int? halaman,
    int? ayat,
    String? surah,
    String? statusPenilaian,
    // GMM
    String? iqroLevel,
    int? iqroHalaman,
    String? statusIqro,
    String? mutabaahTarget,
    String? statusMutabaah,
    String? catatan,
  }) async {
    try {
      final currentUser = ref.read(userDataProvider).value;
      if (currentUser == null) {
        return;
      }

      final result = await ref.read(createProgresHafalanProvider).call(
            CreateProgresHafalanParams(
              userId: userId,
              programId: programId,
              tanggal: tanggal,
              currentUserRole: currentUser.role,
              juz: juz,
              halaman: halaman,
              ayat: ayat,
              surah: surah,
              statusPenilaian: statusPenilaian,
              iqroLevel: iqroLevel,
              iqroHalaman: iqroHalaman,
              statusIqro: statusIqro,
              mutabaahTarget: mutabaahTarget,
              statusMutabaah: statusMutabaah,
              catatan: catatan,
            ),
          );

      if (result.isSuccess) {
        getProgresHafalan(userId);
      }
    } catch (e) {
      debugPrint('Error creating progres: $e');
    }
  }

  // Update Progres
  Future<void> updateProgres(ProgresHafalan progres) async {
    try {
      final currentUser = ref.read(userDataProvider).value;
      if (currentUser == null) {
        return;
      }

      final result = await ref.read(updateProgresHafalanProvider).call(
            UpdateProgresHafalanParams(
              id: progres.id,
              userId: progres.userId,
              programId: progres.programId,
              tanggal: progres.tanggal,
              currentUserRole: currentUser.role,
              juz: progres.juz,
              halaman: progres.halaman,
              ayat: progres.ayat,
              surah: progres.surah,
              statusPenilaian: progres.statusPenilaian,
              iqroLevel: progres.iqroLevel,
              iqroHalaman: progres.iqroHalaman,
              statusIqro: progres.statusIqro,
              mutabaahTarget: progres.mutabaahTarget,
              statusMutabaah: progres.statusMutabaah,
              catatan: progres.catatan,
              createdAt: progres.createdAt,
              createdBy: progres.createdBy,
            ),
          );

      if (result.isSuccess) {
        getProgresHafalan(progres.userId);
      }
    } catch (e) {
      debugPrint('Error updating progres: $e');
    }
  }

  // Delete Progres
  Future<void> deleteProgres(String id, String userId) async {
    try {
      final currentUser = ref.read(userDataProvider).value;
      if (currentUser == null) {
        return;
      }

      final result = await ref.read(deleteProgresHafalanProvider).call(
            DeleteProgresHafalanParams(
              id: id,
              userId: userId,
              currentUserRole: currentUser.role,
            ),
          );

      if (result.isSuccess) {
        getProgresHafalan(userId);
      }
    } catch (e) {
      debugPrint('Error deleting progres: $e');
    }
  }
}
