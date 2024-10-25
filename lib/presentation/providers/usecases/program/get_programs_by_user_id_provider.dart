import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/program/get_programs_by_user_id/get_programs_by_user_id.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart';

part 'get_programs_by_user_id_provider.g.dart';

// Provider untuk mengambil daftar program yang diikuti santri
// Digunakan untuk dashboard santri dan monitoring
@riverpod
GetProgramsByUserId getProgramsByUserId(GetProgramsByUserIdRef ref) =>
    GetProgramsByUserId(
      programRepository: ref.watch(programRepositoryProvider),
    );
