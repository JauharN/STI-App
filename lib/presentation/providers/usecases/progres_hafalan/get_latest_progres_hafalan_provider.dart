import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/get_latest_progres_hafalan/get_latest_progres_hafalan.dart';
import 'package:sti_app/presentation/providers/repositories/progres_hafalan_repository/progres_hafalan_repository_provider.dart';

part 'get_latest_progres_hafalan_provider.g.dart';

// Provider untuk melihat progres hafalan terbaru santri
@riverpod
GetLatestProgresHafalan getLatestProgresHafalan(
        GetLatestProgresHafalanRef ref) =>
    GetLatestProgresHafalan(
      progresHafalanRepository: ref.watch(progresHafalanRepositoryProvider),
    );
