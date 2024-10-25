import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/delete_presensi/delete_presensi.dart';
import 'package:sti_app/presentation/providers/repositories/presensi_repository/presensi_repository_provider.dart';

part 'delete_presensi_provider.g.dart';

// Provider untuk menghapus data presensi (untuk admin)
@riverpod
DeletePresensi deletePresensi(DeletePresensiRef ref) => DeletePresensi(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
