import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/update_presensi/update_presensi.dart';
import 'package:sti_app/presentation/providers/repositories/presensi_repository/presensi_repository_provider.dart';

part 'update_presensi_provider.g.dart';

// Provider untuk mengupdate data presensi (untuk admin)
@riverpod
UpdatePresensi updatePresensi(UpdatePresensiRef ref) => UpdatePresensi(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
