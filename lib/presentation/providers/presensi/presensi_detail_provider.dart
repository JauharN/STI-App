import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/entities/presensi/detail_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/presentation/providers/user_data/user_data_provider.dart';
import 'package:sti_app/presentation/providers/usecases/presensi/get_detail_presensi_provider.dart';

import '../../../domain/usecase/presensi/get_detail_presensi/get_detail_presensi.dart';

part 'presensi_detail_provider.g.dart';

@riverpod
class PresensiDetailState extends _$PresensiDetailState {
  @override
  Future<DetailPresensi> build(String programId) async {
    // Reset state ketika rebuild
    state = const AsyncLoading();

    try {
      // Ambil GetDetailPresensi usecase dari provider
      final getDetailPresensi = ref.read(getDetailPresensiProvider);

      // Ambil user yang sedang login
      final user = ref.read(userDataProvider).valueOrNull;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      // Dapatkan bulan dan tahun saat ini
      final now = DateTime.now();
      final currentMonth = DateFormat('MM').format(now);
      final currentYear = DateFormat('yyyy').format(now);

      // Panggil usecase dengan parameter yang diperlukan
      final result = await getDetailPresensi(
        GetDetailPresensiParams(
          userId: user.uid,
          programId: programId,
          bulan: currentMonth,
          tahun: currentYear,
        ),
      );

      // Handle hasil dari usecase
      return switch (result) {
        Success(value: final presensi) => presensi,
        Failed(:final message) => throw Exception(message),
      };
    } catch (e, stackTrace) {
      // Log error untuk debugging
      print('Error in PresensiDetailState: $e\n$stackTrace');
      // Re-throw untuk ditangkap oleh error handler di UI
      rethrow;
    }
  }

  // Method untuk refresh data presensi
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Provider untuk mengakses data program
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
