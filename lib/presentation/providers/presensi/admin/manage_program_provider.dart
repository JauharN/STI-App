import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/presensi/program_detail.dart';
import '../../../../domain/entities/program.dart';
import '../../../../domain/entities/result.dart';
import '../../../states/manage_program_state.dart';
import '../../repositories/program_repository/program_repository_provider.dart';
import '../../repositories/user_repository/user_repository_provider.dart';

part 'manage_program_provider.g.dart';

@riverpod
class ManageProgramController extends _$ManageProgramController {
  @override
  Future<ManageProgramState> build() async {
    return _fetchProgramList();
  }

  Future<ManageProgramState> _fetchProgramList() async {
    try {
      final programRepository = ref.read(programRepositoryProvider);
      final result = await programRepository.getAllPrograms();

      return switch (result) {
        Success(value: final programList) => ManageProgramState.loaded(
            await Future.wait(programList.map((program) async {
              // Get enrolled santri count
              final enrolledSantri = await ref
                  .read(userRepositoryProvider)
                  .getSantriByProgramId(program.id);

              return ProgramDetail(
                id: program.id,
                name: program.nama,
                description: program.deskripsi,
                schedule: program.jadwal,
                totalMeetings: program.totalPertemuan ?? 8,
                location: program.lokasi,
                teacherIds: program.pengajarIds,
                teacherNames: program.pengajarNames,
                enrolledSantriIds: enrolledSantri.isSuccess
                    ? enrolledSantri.resultValue!.map((s) => s.uid).toList()
                    : [],
                createdAt: program.createdAt,
                updatedAt: program.updatedAt,
              );
            }).toList()),
          ),
        Failed(:final message) => ManageProgramState.error(message),
      };
    } catch (e) {
      return ManageProgramState.error(e.toString());
    }
  }

  Future<Result<void>> createProgram({
    required String name,
    required String description,
    required List<String> schedule,
    required int totalMeetings,
    String? location,
    List<String>? teacherIds,
    List<String>? teacherNames,
  }) async {
    state = const AsyncValue.loading();
    try {
      final programRepository = ref.read(programRepositoryProvider);
      final result = await programRepository.createProgram(
        Program(
          id: '', // Will be generated
          nama: name,
          deskripsi: description,
          jadwal: schedule,
          totalPertemuan: totalMeetings,
          lokasi: location,
          pengajarIds: teacherIds ?? [],
          pengajarNames: teacherNames ?? [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      state = AsyncValue.data(await _fetchProgramList());
      return result.isSuccess
          ? const Result.success(null)
          : Result.failed(result.errorMessage!);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateProgram({
    required String programId,
    String? name,
    String? description,
    List<String>? schedule,
    int? totalMeetings,
    String? location,
    List<String>? teacherIds,
    List<String>? teacherNames,
  }) async {
    state = const AsyncValue.loading();
    try {
      final programRepository = ref.read(programRepositoryProvider);
      final currentProgram = await programRepository.getProgramById(programId);

      if (currentProgram case Failed(:final message)) {
        return Result.failed(message);
      }

      final result = await programRepository.updateProgram(
        currentProgram.resultValue!.copyWith(
          nama: name ?? currentProgram.resultValue!.nama,
          deskripsi: description ?? currentProgram.resultValue!.deskripsi,
          jadwal: schedule ?? currentProgram.resultValue!.jadwal,
          totalPertemuan:
              totalMeetings ?? currentProgram.resultValue!.totalPertemuan,
          lokasi: location ?? currentProgram.resultValue!.lokasi,
          pengajarIds: teacherIds ?? currentProgram.resultValue!.pengajarIds,
          pengajarNames:
              teacherNames ?? currentProgram.resultValue!.pengajarNames,
          updatedAt: DateTime.now(),
        ),
      );

      state = AsyncValue.data(await _fetchProgramList());
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteProgram(String programId) async {
    state = const AsyncValue.loading();
    try {
      final programRepository = ref.read(programRepositoryProvider);

      // Check if program has enrolled santri
      final enrolledSantri = await ref
          .read(userRepositoryProvider)
          .getSantriByProgramId(programId);

      if (enrolledSantri.isSuccess && enrolledSantri.resultValue!.isNotEmpty) {
        return const Result.failed(
            'Tidak dapat menghapus program yang masih memiliki santri terdaftar');
      }

      final result = await programRepository.deleteProgram(programId);
      state = AsyncValue.data(await _fetchProgramList());
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> addSantriToProgram(
    String programId,
    List<String> santriIds,
  ) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      for (final santriId in santriIds) {
        final result = await userRepository.updateUserProgram(
          uid: santriId,
          programId: programId,
        );
        if (result.isFailed) {
          return result;
        }
      }
      state = AsyncValue.data(await _fetchProgramList());
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> removeSantriFromProgram(
    String programId,
    String santriId,
  ) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.removeUserFromProgram(
        uid: santriId,
        programId: programId,
      );
      if (result.isSuccess) {
        state = AsyncValue.data(await _fetchProgramList());
      }
      return result;
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateTeacherAssignment(
    String programId, {
    required List<String>? teacherIds,
    required List<String>? teacherNames,
  }) async {
    return updateProgram(
      programId: programId,
      teacherIds: teacherIds,
      teacherNames: teacherNames,
    );
  }

  // Helper methods for UI filtering/sorting
  Future<void> filterByTeacher(String? teacherId) async {
    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (programList) {
          if (teacherId == null) {
            state = AsyncValue.data(currentState);
            return;
          }
          final filteredList = programList
              .where((program) => program.teacherIds.contains(teacherId))
              .toList();
          state = AsyncValue.data(ManageProgramState.loaded(filteredList));
        },
      );
    });
  }

  Future<void> searchPrograms(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(await _fetchProgramList());
      return;
    }
    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (programList) {
          final filteredList = programList
              .where((program) =>
                  program.name.toLowerCase().contains(query.toLowerCase()) ||
                  program.description
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
          state = AsyncValue.data(ManageProgramState.loaded(filteredList));
        },
      );
    });
  }

  Future<void> sortPrograms(String sortType) async {
    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (list) {
          final sorted = [...list];
          switch (sortType) {
            case 'newest':
              sorted.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            case 'oldest':
              sorted.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
          }
          state = AsyncValue.data(ManageProgramState.loaded(sorted));
        },
      );
    });
  }

  Future<void> filterPrograms(String filterType) async {
    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (list) {
          final filtered = switch (filterType) {
            'has_teacher' =>
              list.where((p) => p.teacherIds.isNotEmpty).toList(),
            _ => list,
          };
          state = AsyncValue.data(ManageProgramState.loaded(filtered));
        },
      );
    });
  }
}
