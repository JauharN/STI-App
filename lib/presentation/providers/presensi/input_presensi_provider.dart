import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../../../domain/entities/presensi/presensi_status.dart';
import '../../../domain/entities/presensi/presensi_summary.dart';
import '../usecases/presensi/create_presensi_pertemuan_provider.dart';

part 'input_presensi_provider.g.dart';

@riverpod
class InputPresensiController extends _$InputPresensiController {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  // Method untuk submit presensi
  Future<void> submitPresensi({
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required String materi,
    required List<SantriPresensi> daftarHadir,
    String? catatan,
  }) async {
    // Set loading state
    state = const AsyncLoading();

    try {
      // Get usecase instance
      final createPresensi = ref.read(createPresensiPertemuanProvider);

      // Generate summary dari daftarHadir
      final summary = _generateSummary(daftarHadir);

      // Execute usecase
      final result = await createPresensi(
        CreatePresensiPertemuanParams(
          programId: programId,
          pertemuanKe: pertemuanKe,
          tanggal: tanggal,
          materi: materi,
          catatan: catatan,
          daftarHadir: daftarHadir,
        ),
      );

      // Handle result
      state = switch (result) {
        Success(value: _) => const AsyncData(null),
        Failed(message: final msg) =>
          AsyncError(Exception(msg), StackTrace.current),
      };
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // Helper method untuk generate summary
  PresensiSummary _generateSummary(List<SantriPresensi> daftarHadir) {
    int hadir = 0, sakit = 0, izin = 0, alpha = 0;

    for (var santri in daftarHadir) {
      switch (santri.status) {
        case PresensiStatus.hadir:
          hadir++;
        case PresensiStatus.sakit:
          sakit++;
        case PresensiStatus.izin:
          izin++;
        case PresensiStatus.alpha:
          alpha++;
      }
    }

    return PresensiSummary(
      totalSantri: daftarHadir.length,
      hadir: hadir,
      sakit: sakit,
      izin: izin,
      alpha: alpha,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Provider untuk validasi input
@riverpod
bool isValidPresensiInput(
  IsValidPresensiInputRef ref, {
  required String programId,
  required int pertemuanKe,
  required String materi,
  required List<SantriPresensi> daftarHadir,
}) {
  // Validasi basic
  if (programId.isEmpty || materi.isEmpty || daftarHadir.isEmpty) {
    return false;
  }

  // Validasi nomor pertemuan
  if (pertemuanKe < 1 || pertemuanKe > 8) {
    return false;
  }

  return true;
}
