import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/usecase/program/add_teacher_to_program/add_teacher_to_program.dart';
import '../../repositories/program_repository/program_repository_provider.dart';

part 'add_teacher_to_program_provider.g.dart';

@riverpod
AddTeacherToProgram addTeacherToProgram(AddTeacherToProgramRef ref) {
  return AddTeacherToProgram(
    programRepository: ref.watch(programRepositoryProvider),
  );
}
