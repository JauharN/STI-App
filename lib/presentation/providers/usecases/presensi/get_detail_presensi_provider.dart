import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/usecase/presensi/get_detail_presensi/get_detail_presensi.dart';
import '../../repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_detail_presensi_provider.g.dart';

@riverpod
GetDetailPresensi getDetailPresensi(GetDetailPresensiRef ref) =>
    GetDetailPresensi(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
