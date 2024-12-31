import 'dart:io';
import '../../domain/entities/result.dart';
import '../../domain/entities/user.dart';

abstract interface class UserRepository {
  // Create user - updated signature tanpa role parameter
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  });

  // Get user
  Future<Result<User>> getUser({
    required String uid,
  });

  // Get users by role - updated return type
  Future<Result<List<User>>> getUsersByRole({
    required UserRole role,
  });

  // Update user
  Future<Result<User>> updateUser({
    required User user,
  });

  // Password management
  Future<Result<void>> resetPassword(String email);

  // Profile picture
  Future<Result<User>> uploadProfilePicture({
    required User user,
    required File imageFile,
  });

  // Santri management
  Future<Result<List<User>>> getAllSantri();

  // Program management
  Future<Result<void>> updateUserProgram({
    required String uid,
    required String programId,
  });

  Future<Result<List<String>>> getUserPrograms({
    required String uid,
  });

  Future<Result<List<User>>> getSantriByProgramId(String programId);

  Future<Result<void>> deleteUser(String uid);

  Future<Result<void>> removeUserFromProgram({
    required String uid,
    required String programId,
  });
}
