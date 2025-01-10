import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/usecase/santri/get_santri_by_program.dart';
import '../../repositories/user_repository/user_repository_provider.dart'; // Diubah dari santri ke user

part 'get_santri_by_program_provider.g.dart';

@riverpod
GetSantriByProgram getSantriByProgram(GetSantriByProgramRef ref) =>
    GetSantriByProgram(
      userRepository:
          ref.watch(userRepositoryProvider), // Diubah dari santriRepository
    );
