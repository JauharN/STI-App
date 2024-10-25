import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/sesi/delete_sesi/delete_sesi.dart';
import 'package:sti_app/presentation/providers/repositories/sesi_repository/sesi_repository_provider.dart';

part 'delete_sesi_provider.g.dart';

// Provider untuk menghapus sesi (khusus admin)
// Digunakan ketika ada pembatalan sesi
@riverpod
DeleteSesi deleteSesi(DeleteSesiRef ref) => DeleteSesi(
      sesiRepository: ref.watch(sesiRepositoryProvider),
      // Tidak perlu programRepository karena hanya operasi hapus
    );
