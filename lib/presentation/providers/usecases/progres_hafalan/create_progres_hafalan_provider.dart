import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/create_progres_hafalan/create_progres_hafalan.dart';
import 'package:sti_app/presentation/providers/repositories/progres_hafalan_repository/progres_hafalan_repository_provider.dart';

part 'create_progres_hafalan_provider.g.dart';

// Provider untuk mencatat progres hafalan baru (untuk admin)
@riverpod
CreateProgresHafalan createProgresHafalan(CreateProgresHafalanRef ref) =>
    CreateProgresHafalan(
      progresHafalanRepository: ref.watch(progresHafalanRepositoryProvider),
    );
