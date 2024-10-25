import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/progres_hafalan/delete_progres_hafalan/delete_progres_hafalan.dart';
import 'package:sti_app/presentation/providers/repositories/progres_hafalan_repository/progres_hafalan_repository_provider.dart';

part 'delete_progres_hafalan_provider.g.dart';

// Provider untuk menghapus data progres hafalan (untuk admin)
@riverpod
DeleteProgresHafalan deleteProgresHafalan(DeleteProgresHafalanRef ref) =>
    DeleteProgresHafalan(
      progresHafalanRepository: ref.watch(progresHafalanRepositoryProvider),
    );
