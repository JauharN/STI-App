import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/sesi/update_sesi/update_sesi.dart';
import 'package:sti_app/presentation/providers/repositories/sesi_repository/sesi_repository_provider.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'update_sesi_provider.g.dart';

// Provider untuk mengupdate informasi sesi (khusus admin)
// Digunakan untuk mengubah jadwal atau materi
@riverpod
UpdateSesi updateSesi(UpdateSesiRef ref) => UpdateSesi(
      sesiRepository: ref.watch(sesiRepositoryProvider),
      programRepository: ref.watch(programRepositoryProvider),
    );
