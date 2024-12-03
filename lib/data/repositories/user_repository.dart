import 'dart:io';
import '../../domain/entities/result.dart';
import '../../domain/entities/user.dart';

abstract interface class UserRepository {
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String role, // 'santri' atau 'admin'
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  });

  Future<Result<User>> getUser({
    required String uid,
  });

  Future<Result<User>> updateUser({
    required User user,
  });

  Future<Result<void>> resetPassword(String email);

  Future<Result<User>> uploadProfilePicture({
    required User user,
    required File imageFile,
  });

  Future<Result<List<User>>> getAllSantri();

  Future<Result<void>> updateUserProgram({
    required String uid,
    required String programId,
  });

  Future<Result<List<String>>> getUserPrograms({
    required String uid,
  });

  Future<Result<List<User>>> getSantriByProgramId(String programId);
}
