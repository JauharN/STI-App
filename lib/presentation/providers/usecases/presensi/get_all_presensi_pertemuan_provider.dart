import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/get_all_presensi_pertemuan/get_all_presensi_pertemuan.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_all_presensi_pertemuan_provider.g.dart';

@riverpod
GetAllPresensiPertemuan getAllPresensiPertemuan(
        GetAllPresensiPertemuanRef ref) =>
    GetAllPresensiPertemuan(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
