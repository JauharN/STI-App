import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/data/firebase/firebase_user_repository.dart';
import 'package:sti_app/data/repositories/user_repository.dart';

part 'user_repository_provider.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) =>
    FirebaseUserRepository();
