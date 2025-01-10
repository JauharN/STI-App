import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/sesi/get_sesi_by_program/get_sesi_by_program.dart';
import 'package:sti_app/presentation/providers/repositories/sesi_repository/sesi_repository_provider.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'get_sesi_by_program_provider.g.dart';

@riverpod
GetSesiByProgram getSesiByProgram(GetSesiByProgramRef ref) => GetSesiByProgram(
      sesiRepository: ref.watch(sesiRepositoryProvider),
      programRepository: ref.watch(programRepositoryProvider),
    );
