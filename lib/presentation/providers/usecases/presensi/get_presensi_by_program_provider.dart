import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/get_presensi_by_program/get_presensi_by_program.dart';
import 'package:sti_app/presentation/providers/repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_presensi_by_program_provider.g.dart';

// Provider untuk melihat presensi per program (untuk admin)
@riverpod
GetPresensiByProgram getPresensiByProgram(GetPresensiByProgramRef ref) =>
    GetPresensiByProgram(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
