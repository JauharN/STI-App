import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/delete_presensi_pertemuan/delete_presensi_pertemuan.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'delete_presensi_pertemuan_provider.g.dart';

@riverpod
DeletePresensiPertemuan deletePresensiPertemuan(
        DeletePresensiPertemuanRef ref) =>
    DeletePresensiPertemuan(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
