import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/sesi/get_upcoming_sesi/get_upcoming_sesi.dart';
import 'package:sti_app/presentation/providers/repositories/sesi_repository/sesi_repository_provider.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'get_upcoming_sesi_provider.g.dart';

// Provider untuk mengambil sesi yang akan datang
// Digunakan untuk reminder dan jadwal terdekat
@riverpod
GetUpcomingSesi getUpcomingSesi(GetUpcomingSesiRef ref) => GetUpcomingSesi(
      sesiRepository: ref.watch(sesiRepositoryProvider),
      programRepository: ref.watch(programRepositoryProvider),
    );
