import 'dart:io';
import '../../domain/entities/result.dart';
import '../../domain/entities/user.dart';

abstract interface class UserRepository {
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String role,
    required List<String> selectedPrograms,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  });

  Future<Result<List<User>>> getAllSantri();

  Future<Result<List<User>>> getUsersByRole({required String role});

  Future<Result<User>> getUser({
    required String uid,
  });

  Future<Result<List<String>>> getUserPrograms({
    required String uid,
  });

  Future<Result<User>> updateUser({
    required User user,
  });

  Future<Result<void>> updateUserProgram({
    required String uid,
    required String programId,
  });

  Future<Result<User>> uploadProfilePicture({
    required User user,
    required File imageFile,
  });

  Future<Result<void>> resetPassword(String email);

  Future<Result<List<User>>> getSantriByProgramId(String programId);

  Future<Result<void>> deleteUser(String uid);

  Future<Result<void>> removeUserFromProgram({
    required String uid,
    required String programId,
  });
}
