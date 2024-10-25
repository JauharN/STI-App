import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/update_program/update_program.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'update_program_provider.g.dart';

// Provider untuk mengupdate informasi program (khusus admin)
// Misalnya mengubah jadwal atau lokasi
@riverpod
UpdateProgram updateProgram(UpdateProgramRef ref) => UpdateProgram(
      programRepository: ref.watch(programRepositoryProvider),
    );
