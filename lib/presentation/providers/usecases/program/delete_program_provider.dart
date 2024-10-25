import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/delete_program/delete_program.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'delete_program_provider.g.dart';

// Provider untuk menghapus program (khusus admin)
// Jarang digunakan karena program STI bersifat tetap
@riverpod
DeleteProgram deleteProgram(DeleteProgramRef ref) => DeleteProgram(
      programRepository: ref.watch(programRepositoryProvider),
    );
