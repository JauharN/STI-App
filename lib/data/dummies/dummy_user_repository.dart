import 'dart:io';

import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';

class DummyUserRepository implements UserRepository {
  @override
  Future<Result<User>> createUser(
      {required String uid,
      required String email,
      required String name,
      required String role,
      String? photoUrl}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<Result<List<User>>> getAllSantri() {
    // TODO: implement getAllSantri
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> getUser({required String uid}) async {
    await Future.delayed(const Duration(seconds: 1));
    return Result.success(
      User(
        uid: uid,
        name: 'Dummy Santri',
        email: 'santri@sti.com',
        role: 'santri',
      ),
    );
  }

  @override
  Future<Result<List<String>>> getUserPrograms({required String uid}) {
    // TODO: implement getUserPrograms
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> updateUser({required User user}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> updateUserProgram(
      {required String uid, required String programId}) {
    // TODO: implement updateUserProgram
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> uploadProfilePicture(
      {required User user, required File imageFile}) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
