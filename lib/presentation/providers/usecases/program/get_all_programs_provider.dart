import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/get_all_programs/get_all_programs.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'get_all_programs_provider.g.dart';

// Provider untuk mengambil daftar semua program yang ada
// Digunakan untuk tampilan awal dan pilihan program
@riverpod
GetAllPrograms getAllPrograms(GetAllProgramsRef ref) => GetAllPrograms(
      programRepository: ref.watch(programRepositoryProvider),
    );
