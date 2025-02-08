import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/presentation/providers/usecases/progres_hafalan/get_latest_progres_hafalan_provider.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/get_latest_progres_hafalan/get_latest_progres_hafalan.dart';

import '../user_data/user_data_provider.dart';

part 'progres_detail_provider.g.dart';

@riverpod
class ProgresDetailNotifier extends _$ProgresDetailNotifier {
  @override
  AsyncValue<ProgresHafalan?> build() => const AsyncValue.data(null);

  // Get Latest Progres Detail
  Future<void> getLatestProgres(String userId) async {
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

      final result = await ref.read(getLatestProgresHafalanProvider).call(
            GetLatestProgresHafalanParams(
              userId: userId,
              requestingUserId: currentUser.uid,
              currentUserRole: currentUser.role,
            ),
          );

      switch (result) {
        case Success(value: final progres):
          state = AsyncValue.data(progres);
        case Failed(message: final message):
          state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Get Tahfidz Detail Fields
  String? get currentJuz => state.valueOrNull?.juz?.toString();
  String? get currentHalaman => state.valueOrNull?.halaman?.toString();
  String? get currentAyat => state.valueOrNull?.ayat?.toString();
  String? get currentSurah => state.valueOrNull?.surah;
  String? get currentStatusPenilaian => state.valueOrNull?.statusPenilaian;

  // Get GMM Detail Fields
  String? get currentIqroLevel => state.valueOrNull?.iqroLevel;
  String? get currentIqroHalaman => state.valueOrNull?.iqroHalaman?.toString();
  String? get currentStatusIqro => state.valueOrNull?.statusIqro;
  String? get currentMutabaahTarget => state.valueOrNull?.mutabaahTarget;
  String? get currentStatusMutabaah => state.valueOrNull?.statusMutabaah;

  // Get Common Fields
  String? get currentCatatan => state.valueOrNull?.catatan;
  DateTime? get currentTanggal => state.valueOrNull?.tanggal;
  String? get currentProgramId => state.valueOrNull?.programId;

  // Helper Methods
  bool get isTahfidz => currentProgramId == 'TAHFIDZ';
  bool get isGMM => currentProgramId == 'GMM';

  bool get isLancar => isTahfidz
      ? currentStatusPenilaian == 'Lancar'
      : currentStatusIqro == 'Lancar';

  bool get isSelesai => isTahfidz
      ? currentStatusPenilaian != null
      : currentStatusMutabaah == 'Tercapai';

  // Get Formatted Status
  String getFormattedStatus() {
    if (state.valueOrNull == null) return '-';

    if (isTahfidz) {
      return currentStatusPenilaian ?? '-';
    } else {
      return 'Iqro: ${currentStatusIqro ?? '-'}\n'
          'Mutabaah: ${currentStatusMutabaah ?? '-'}';
    }
  }

  // Get Formatted Progress
  String getFormattedProgress() {
    if (state.valueOrNull == null) return '-';

    if (isTahfidz) {
      return 'Juz ${currentJuz ?? '-'}, '
          'Halaman ${currentHalaman ?? '-'}, '
          'Ayat ${currentAyat ?? '-'}\n'
          'Surah: ${currentSurah ?? '-'}';
    } else {
      return 'Iqro Level ${currentIqroLevel ?? '-'}, '
          'Halaman ${currentIqroHalaman ?? '-'}\n'
          'Target: ${currentMutabaahTarget ?? '-'}';
    }
  }
}
