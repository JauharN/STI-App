import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/get_progres_hafalan_by_user/get_progres_hafalan_by_user.dart';
import 'package:sti_app/presentation/providers/repositories/progres_hafalan_repository/progres_hafalan_repository_provider.dart';

part 'get_progres_hafalan_by_user_provider.g.dart';

// Provider untuk melihat riwayat progres hafalan santri
@riverpod
GetProgresHafalanByUser getProgresHafalanByUser(
        GetProgresHafalanByUserRef ref) =>
    GetProgresHafalanByUser(
      progresHafalanRepository: ref.watch(progresHafalanRepositoryProvider),
    );
