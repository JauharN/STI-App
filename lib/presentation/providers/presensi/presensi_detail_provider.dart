import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/detail_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/usecase/presensi/get_detail_presensi/get_detail_presensi.dart';

import '../usecases/presensi/get_detail_presensi_provider.dart';
import '../user_data/user_data_provider.dart';

part 'presensi_detail_provider.g.dart';

@riverpod
class PresensiDetailState extends _$PresensiDetailState {
  @override
  Future<DetailPresensi> build(String programId) async {
    state = const AsyncLoading();

    try {
      // Get usecase instance
      final getDetailPresensi = ref.read(getDetailPresensiProvider);

      // Get current user
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = DateFormat('MM').format(now);
      final currentYear = DateFormat('yyyy').format(now);

      // Call usecase with string role
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

  // Method untuk refresh data presensi
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> deletePresensi(String presensiId) async {
    try {
      // TODO: Implementasi delete di repository
      // Untuk sementara kita hanya refresh data
      await refresh();
    } catch (e) {
      throw Exception('Gagal menghapus presensi: ${e.toString()}');
    }
  }
}

// Program name helper provider
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
