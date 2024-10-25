import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/update_progres_hafalan/update_progres_hafalan.dart';
import 'package:sti_app/presentation/providers/repositories/progres_hafalan_repository/progres_hafalan_repository_provider.dart';

part 'update_progres_hafalan_provider.g.dart';

// Provider untuk mengupdate data progres hafalan (untuk admin)
@riverpod
UpdateProgresHafalan updateProgresHafalan(UpdateProgresHafalanRef ref) =>
    UpdateProgresHafalan(
      progresHafalanRepository: ref.watch(progresHafalanRepositoryProvider),
    );
