import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/presensi/santri_detail.dart';
import '../../../../domain/entities/result.dart';
import '../../../states/manage_santri_state.dart';
import '../../repositories/user_repository/user_repository_provider.dart';

part 'manage_santri_provider.g.dart';

@riverpod
class ManageSantriController extends _$ManageSantriController {
  @override
  Future<ManageSantriState> build() async {
    return _fetchSantriList();
  }

  Future<ManageSantriState> _fetchSantriList() async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.getAllSantri();

      return switch (result) {
        Success(value: final santriList) => ManageSantriState.loaded(
            santriList
                .map((user) => SantriDetail(
                      id: user.uid,
                      name: user.name,
                      email: user.email,
                      enrolledPrograms: const [],
                      photoUrl: user.photoUrl,
                      phoneNumber: user.phoneNumber,
                      address: user.address,
                      dateOfBirth: user.dateOfBirth,
                    ))
                .toList(),
          ),
        Failed(:final message) => ManageSantriState.error(message),
      };
    } catch (e) {
      return ManageSantriState.error(e.toString());
    }
  }

  Future<Result<void>> createSantri({
    required String name,
    required String email,
    required String password,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    List<String>? programIds,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final uid = const Uuid().v4();

      final result = await userRepository.createUser(
        uid: uid,
        email: email,
        name: name,
        role: 'santri',
        photoUrl: photoUrl,
      );

      if (result.isSuccess && programIds != null) {
        for (final programId in programIds) {
          await userRepository.updateUserProgram(
            uid: result.resultValue!.uid,
            programId: programId,
          );
        }
      }

      state = AsyncValue.data(await _fetchSantriList());

      return result.isSuccess
          ? const Result.success(null)
          : Result.failed(result.errorMessage!);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateSantri({
    required String santriId,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    List<String>? programIds,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final currentUser = await userRepository.getUser(uid: santriId);

      if (currentUser case Failed(:final message)) {
        return Result.failed(message);
      }

      final updateResult = await userRepository.updateUser(
        user: currentUser.resultValue!.copyWith(
          name: name ?? currentUser.resultValue!.name,
          photoUrl: photoUrl ?? currentUser.resultValue!.photoUrl,
          phoneNumber: phoneNumber ?? currentUser.resultValue!.phoneNumber,
          address: address ?? currentUser.resultValue!.address,
          dateOfBirth: dateOfBirth ?? currentUser.resultValue!.dateOfBirth,
        ),
      );

      if (updateResult.isSuccess && programIds != null) {
        for (final programId in programIds) {
          await userRepository.updateUserProgram(
            uid: santriId,
            programId: programId,
          );
        }
      }

      state = AsyncValue.data(await _fetchSantriList());

      return updateResult.isSuccess
          ? const Result.success(null)
          : Result.failed(updateResult.errorMessage!);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteSantri(String santriId) async {
    state = const AsyncValue.loading();

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.deleteUser(santriId);

      state = AsyncValue.data(await _fetchSantriList());
      return result;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return Result.failed(e.toString());
    }
  }

  Future<void> searchSantri(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(await _fetchSantriList());
      return;
    }

    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (santriList) {
          final filteredList = santriList
              .where((santri) =>
                  santri.name.toLowerCase().contains(query.toLowerCase()) ||
                  santri.email.toLowerCase().contains(query.toLowerCase()))
              .toList();
          state = AsyncValue.data(ManageSantriState.loaded(filteredList));
        },
      );
    });
  }

  Future<void> filterByProgram(String programId) async {
    if (programId == 'all') {
      state = AsyncValue.data(await _fetchSantriList());
      return;
    }

    state.whenData((currentState) {
      currentState.whenOrNull(
        loaded: (santriList) {
          final filteredList = santriList
              .where((santri) => santri.enrolledPrograms.contains(programId))
              .toList();
          state = AsyncValue.data(ManageSantriState.loaded(filteredList));
        },
      );
    });
  }
}