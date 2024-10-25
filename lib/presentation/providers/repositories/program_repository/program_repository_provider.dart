import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/data/firebase/firebase_program_repository.dart';
import 'package:sti_app/data/repositories/program_repository.dart';

part 'program_repository_provider.g.dart';

@riverpod
ProgramRepository programRepository(ProgramRepositoryRef ref) =>
    FirebaseProgramRepository();
