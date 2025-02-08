import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/presensi/detail_presensi.dart';
import '../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../domain/entities/presensi/presensi_status.dart';
import '../../../domain/entities/presensi/santri_presensi.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/usecase/presensi/get_detail_presensi/get_detail_presensi.dart';
import '../../../domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../repositories/presensi_repository/presensi_repository_provider.dart';
import '../repositories/user_repository/user_repository_provider.dart';
import '../usecases/presensi/get_detail_presensi_provider.dart';
import '../usecases/presensi/create_presensi_pertemuan_provider.dart';
import '../user_data/user_data_provider.dart';

part 'presensi_detail_provider.g.dart';

@riverpod
class PresensiDetailState extends _$PresensiDetailState {
  @override
  Future<DetailPresensi> build(String programId) async {
    state = const AsyncLoading();
    try {
      final getDetailPresensi = ref.read(getDetailPresensiProvider);
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      final now = DateTime.now();
      final currentMonth = DateFormat('MM').format(now);
      final currentYear = DateFormat('yyyy').format(now);

      final result = await getDetailPresensi(
        GetDetailPresensiParams(
          userId: user.uid,
          requestingUserId: user.uid,
          programId: programId,
          bulan: currentMonth,
          tahun: currentYear,
          currentUserRole: user.role,
        ),
      );

      return switch (result) {
        Success(value: final presensi) => presensi,
        Failed(:final message) => throw Exception(message),
      };
    } catch (e, stackTrace) {
      print('Error in PresensiDetailState: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> createPresensi({
    required String programId,
    required int pertemuanKe,
    required DateTime tanggal,
    required String materi,
    required List<SantriPresensi> daftarHadir,
    String? catatan,
  }) async {
    try {
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) throw Exception('User tidak ditemukan');

      if (user.role != 'admin' && user.role != 'superAdmin') {
        throw Exception('Hanya admin yang dapat membuat presensi');
      }

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

      if (result case Failed(:final message)) {
        throw Exception(message);
      }
      await refresh();
    } catch (e) {
      throw Exception('Gagal membuat presensi: ${e.toString()}');
    }
  }

  Future<void> updatePresensi(PresensiPertemuan pertemuan) async {
    try {
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) throw Exception('User tidak ditemukan');

      if (user.role != 'admin' && user.role != 'superAdmin') {
        throw Exception('Hanya admin yang dapat mengupdate presensi');
      }

      final repository = ref.read(presensiRepositoryProvider);
      final result = await repository.updatePresensiPertemuan(pertemuan);

      if (result case Failed(:final message)) {
        throw Exception(message);
      }
      await refresh();
    } catch (e) {
      throw Exception('Gagal mengupdate presensi: ${e.toString()}');
    }
  }

  Future<void> deletePresensi(String presensiId) async {
    try {
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) throw Exception('User tidak ditemukan');

      if (user.role != 'admin' && user.role != 'superAdmin') {
        throw Exception('Hanya admin yang dapat menghapus presensi');
      }

      final repository = ref.read(presensiRepositoryProvider);
      final result = await repository.deletePresensiPertemuan(presensiId);

      if (result case Failed(:final message)) {
        throw Exception(message);
      }
      await refresh();
    } catch (e) {
      throw Exception('Gagal menghapus presensi: ${e.toString()}');
    }
  }

  Future<void> bulkUpdatePresensi({
    required String programId,
    required List<String> santriIds,
    required PresensiStatus status,
    required int pertemuanKe,
    String? keterangan,
  }) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final daftarHadir = await Future.wait(
        santriIds.map((id) async {
          final user = await userRepository.getUser(uid: id);
          return SantriPresensi(
            santriId: id,
            santriName: user.resultValue?.name ?? '',
            status: status,
            keterangan: keterangan,
          );
        }),
      );

      await createPresensi(
        programId: programId,
        pertemuanKe: pertemuanKe,
        tanggal: DateTime.now(),
        materi: 'Bulk Update',
        daftarHadir: daftarHadir,
        catatan: 'Bulk update presensi',
      );
    } catch (e) {
      throw Exception('Gagal melakukan bulk update: ${e.toString()}');
    }
  }
}

@riverpod
Future<String> programName(ProgramNameRef ref, String programId) async {
  switch (programId) {
    case 'TAHFIDZ':
      return 'Program Tahfidz';
    case 'GMM':
      return 'Program GMM';
    case 'IFIS':
      return 'Program IFIS';
    default:
      return 'Program Tidak Dikenal';
  }
}
