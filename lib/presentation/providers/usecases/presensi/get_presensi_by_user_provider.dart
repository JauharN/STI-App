import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/get_presensi_by_user/get_presensi_by_user.dart';
import 'package:sti_app/presentation/providers/repositories/presensi_repository/presensi_repository_provider.dart';

part 'get_presensi_by_user_provider.g.dart';

// Provider untuk mengambil riwayat presensi santri
@riverpod
GetPresensiByUser getPresensiByUser(GetPresensiByUserRef ref) =>
    GetPresensiByUser(
      presensiRepository: ref.watch(presensiRepositoryProvider),
    );
