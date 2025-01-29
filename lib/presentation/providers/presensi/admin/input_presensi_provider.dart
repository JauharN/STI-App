import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../../../../domain/entities/presensi/presensi_status.dart';
import '../../repositories/user_repository/user_repository_provider.dart';
import '../../usecases/presensi/create_presensi_pertemuan_provider.dart';
import '../../user_data/user_data_provider.dart';

part 'input_presensi_provider.g.dart';

@riverpod
class InputPresensiController extends _$InputPresensiController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> submitPresensi({
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required String materi,
    required List<SantriPresensi> daftarHadir,
    String? catatan,
  }) async {
    state = const AsyncLoading();

    try {
      // Ambil user role saat ini
      final user = ref.read(userDataProvider).value;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      final currentUserRole = user.role;

      // Get usecase instance
      final createPresensi = ref.read(createPresensiPertemuanProvider);

      // Gunakan parameter baru (tanpa summary)
      final result = await createPresensi(
        CreatePresensiPertemuanParams(
          programId: programId,
          pertemuanKe: pertemuanKe,
          tanggal: tanggal,
          materi: materi,
          catatan: catatan,
          daftarHadir: daftarHadir,
          currentUserRole: currentUserRole, // Tambahan validasi role
        ),
      );

      state = switch (result) {
        Success(value: _) => const AsyncData(null),
        Failed(message: final msg) =>
          AsyncError(Exception(msg), StackTrace.current),
      };
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> bulkUpdatePresensi({
    required String programId,
    required List<String> santriIds,
    required PresensiStatus status,
    String? keterangan,
    required int pertemuanKe,
  }) async {
    state = const AsyncLoading();
    try {
      // Get santri details first
      final userRepository = ref.read(userRepositoryProvider);
      final daftarHadir = await Future.wait(
        santriIds.map((id) async {
          final user = await userRepository.getUser(uid: id);
          return SantriPresensi(
            santriId: id,
            santriName: user.resultValue?.name ?? '', // Fix missing santriName
            status: status,
            keterangan: keterangan,
          );
        }),
      );

      await submitPresensi(
        programId: programId,
        pertemuanKe: pertemuanKe,
        tanggal: DateTime.now(),
        materi: 'Bulk Update',
        daftarHadir: daftarHadir,
        catatan: 'Bulk update presensi',
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
bool isValidPresensiInput(
  IsValidPresensiInputRef ref, {
  required String programId,
  required int pertemuanKe,
  required String materi,
  required List<SantriPresensi> daftarHadir,
}) {
  if (programId.isEmpty || materi.isEmpty || daftarHadir.isEmpty) {
    return false;
  }

  if (pertemuanKe < 1 || pertemuanKe > 8) {
    return false;
  }

  return true;
}
