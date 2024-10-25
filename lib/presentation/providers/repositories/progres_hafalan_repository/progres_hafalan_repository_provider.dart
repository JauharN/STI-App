import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/data/firebase/firebase_progres_hafalan_repository.dart';
import 'package:sti_app/data/repositories/progres_hafalan_repository.dart';

part 'progres_hafalan_repository_provider.g.dart';

@riverpod
ProgresHafalanRepository progresHafalanRepository(
        ProgresHafalanRepositoryRef ref) =>
    FirebaseProgresHafalanRepository();
