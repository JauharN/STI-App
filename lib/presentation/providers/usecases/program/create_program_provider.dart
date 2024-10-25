import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/create_program/create_program.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'create_program_provider.g.dart';

// Provider untuk membuat program baru (khusus admin)
// Biasanya untuk inisialisasi program Tahfidz, GMM, IFIS
@riverpod
CreateProgram createProgram(CreateProgramRef ref) => CreateProgram(
      programRepository: ref.watch(programRepositoryProvider),
    );
