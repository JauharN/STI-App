import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/data/firebase/firebase_presensi_repository.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';

part 'presensi_repository_provider.g.dart';

@riverpod
PresensiRepository presensiRepository(PresensiRepositoryRef ref) =>
    FirebasePresensiRepository();
