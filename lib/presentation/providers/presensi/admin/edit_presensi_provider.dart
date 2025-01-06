import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../../../domain/entities/result.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'edit_presensi_provider.g.dart';

@riverpod
Future<PresensiPertemuan> editPresensiData(
  EditPresensiDataRef ref,
  String programId,
  String presensiId,
) async {
  final repository = ref.watch(presensiRepositoryProvider);
  final result = await repository.getPresensiById(presensiId);

  return switch (result) {
    Success(value: final presensi) => presensi,
    Failed(:final message) => throw Exception(message),
  };
}
