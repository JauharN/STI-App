import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/get_program_by_id/get_program_by_id.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'get_program_by_id_provider.g.dart';

// Provider untuk mengambil detail program tertentu
// Digunakan untuk halaman detail program dan validasi
@riverpod
GetProgramById getProgramById(GetProgramByIdRef ref) => GetProgramById(
      programRepository: ref.watch(programRepositoryProvider),
    );
