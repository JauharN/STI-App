import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/create_presensi_pertemuan/create_presensi_pertemuan.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'create_presensi_pertemuan_provider.g.dart';

@riverpod
CreatePresensiPertemuan createPresensiPertemuan(
        CreatePresensiPertemuanRef ref) =>
    CreatePresensiPertemuan(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
