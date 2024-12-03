import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/update_presensi_pertemuan/update_presensi_pertemuan.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'update_presensi_pertemuan_provider.g.dart';

@riverpod
UpdatePresensiPertemuan updatePresensiPertemuan(
        UpdatePresensiPertemuanRef ref) =>
    UpdatePresensiPertemuan(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
