import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/presensi/create_presensi/create_presensi.dart';
import 'package:sti_app/presentation/providers/repositories/presensi_repository/presensi_repository_provider.dart';

part 'create_presensi_provider.g.dart';

@riverpod
CreatePresensi createPresensi(CreatePresensiRef ref) =>
    CreatePresensi(presensiRepository: ref.watch(presensiRepositoryProvider));
