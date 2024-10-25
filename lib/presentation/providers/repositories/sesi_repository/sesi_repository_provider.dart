import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/data/firebase/firebase_sesi_repository.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';

part 'sesi_repository_provider.g.dart';

@riverpod
SesiRepository sesiRepository(SesiRepositoryRef ref) =>
    FirebaseSesiRepository();
