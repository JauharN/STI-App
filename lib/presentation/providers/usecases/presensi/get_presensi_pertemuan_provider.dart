import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/get_presensi_pertemuan/get_presensi_pertemuan.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_presensi_pertemuan_provider.g.dart';

@riverpod
GetPresensiPertemuan getPresensiPertemuan(GetPresensiPertemuanRef ref) =>
    GetPresensiPertemuan(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
