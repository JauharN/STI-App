import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../../../../domain/entities/presensi/presensi_status.dart';
import '../../repositories/user_repository/user_repository_provider.dart';
import '../../usecases/presensi/create_presensi_pertemuan_provider.dart';
import '../../user_data/user_data_provider.dart';
import 'package:flutter/foundation.dart';

part 'input_presensi_provider.g.dart';

@riverpod
class InputPresensiController extends _$InputPresensiController {
  @override
  FutureOr<void> build() async {
    // Initialize with empty state
    return;
  }

  Future<Result<void>> submitPresensi({
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required String materi,
    required List<SantriPresensi> daftarHadir,
    String? catatan,
  }) async {
    try {
      // Validate input first
      if (!ref.read(isValidPresensiInputProvider(
        programId: programId,
        pertemuanKe: pertemuanKe,
        materi: materi,
        daftarHadir: daftarHadir,
      ))) {
        return const Result.failed('Input tidak valid');
      }

      state = const AsyncLoading();

      // Get current user
      final user = ref.read(userDataProvider).value;
      if (user == null) {
        return const Result.failed('User tidak ditemukan');
      }

      debugPrint('Submitting presensi for program: $programId');
      debugPrint('DaftarHadir count: ${daftarHadir.length}');

      final createPresensi = ref.read(createPresensiPertemuanProvider);
      final result = await createPresensi(
        CreatePresensiPertemuanParams(
          programId: programId,
          pertemuanKe: pertemuanKe,
          tanggal: tanggal,
          materi: materi,
          daftarHadir: daftarHadir,
          catatan: catatan,
          userId: user.uid,
          currentUserRole: user.role,
        ),
      );

      // Update state based on result
      // Update state based on result
      if (result.isSuccess) {
        debugPrint('Presensi submitted successfully');
        state = const AsyncData(null);
      } else {
        debugPrint('Failed to submit presensi: ${result.errorMessage}');
        state = AsyncError(Exception(result.errorMessage), StackTrace.current);
      }

      return result;
    } catch (e, stack) {
      debugPrint('Error submitting presensi: $e');
      state = AsyncError(e, stack);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> bulkUpdatePresensi({
    required String programId,
    required List<String> santriIds,
    required PresensiStatus status,
    required int pertemuanKe,
    String? keterangan,
  }) async {
    try {
      state = const AsyncLoading();
      debugPrint('Starting bulk update for ${santriIds.length} santri');

      final userRepository = ref.read(userRepositoryProvider);
      final daftarHadir = await Future.wait(
        santriIds.map((id) async {
          final userResult = await userRepository.getUser(uid: id);
          if (!userResult.isSuccess) {
            debugPrint('Failed to get user data for ID: $id');
            throw Exception('Failed to get user data');
          }

          final user = userResult.resultValue!;
          return SantriPresensi(
            santriId: id,
            santriName: user.name,
            status: status,
            keterangan: keterangan,
          );
        }),
      );

      return submitPresensi(
        programId: programId,
        pertemuanKe: pertemuanKe,
        tanggal: DateTime.now(),
        materi: 'Bulk Update',
        daftarHadir: daftarHadir,
        catatan: 'Bulk update presensi',
      );
    } catch (e, stack) {
      debugPrint('Error in bulk update: $e');
      state = AsyncError(e, stack);
      return Result.failed(e.toString());
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
    debugPrint('Invalid input: Empty required fields');
    return false;
  }
  if (pertemuanKe < 1 || pertemuanKe > 8) {
    debugPrint('Invalid pertemuan ke: $pertemuanKe');
    return false;
  }

  // Validate daftarHadir
  for (var presensi in daftarHadir) {
    if (presensi.santriId.isEmpty || presensi.santriName.isEmpty) {
      debugPrint('Invalid santri data in daftarHadir');
      return false;
    }
  }

  return true;
}
