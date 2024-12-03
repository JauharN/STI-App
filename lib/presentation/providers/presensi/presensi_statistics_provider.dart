import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presensi_statistics_provider.g.dart';

@riverpod
class PresensiStatistics extends _$PresensiStatistics {
  @override
  Future<void> build(String programId) async {}

  Future<bool> hasReferences(String presensiId) async {
    // Untuk saat ini return false saja dulu
    // Nanti bisa diimplementasi sesuai kebutuhan
    return false;
  }
}
