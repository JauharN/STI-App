import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../repositories/user_repository.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/user.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  FirebaseUserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  // Helper method untuk konversi UserRole ke String
  String _userRoleToString(UserRole role) {
    return role.toString().split('.').last;
  }

  UserRole _stringToUserRole(String roleStr) {
    final normalizedRole = roleStr.trim().toLowerCase();
    debugPrint('Converting role string: $normalizedRole');

    switch (normalizedRole) {
      case 'santri':
        return UserRole.santri;
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        debugPrint('Invalid role encountered: $normalizedRole');
        return UserRole.santri; // Default to santri for safety
    }
  }

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    try {
      if (!_validateUserData(email: email, name: name)) {
        debugPrint('Data validation failed');
        return const Result.failed('Invalid user data provided');
      }

      final userData = {
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'role': role.toJson(), // Menggunakan method toJson dari enum UserRole
        'isActive': true,
        'photoUrl': photoUrl?.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'address': address?.trim(),
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        'programs': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('Attempting to create user with data: ${userData.toString()}');

      // Reference ke dokumen user
      final userRef = _firebaseFirestore.collection('users').doc(uid);

      // Cek existing user
      final existingUser = await userRef.get();
      if (existingUser.exists) {
        debugPrint('User with UID $uid already exists');
        return const Result.failed('User already exists');
      }

      // Gunakan transaction untuk atomic write
      await _firebaseFirestore.runTransaction((transaction) async {
        transaction.set(userRef, userData);
      });

      // Verifikasi data tersimpan
      final savedDoc = await userRef.get();
      if (!savedDoc.exists) {
        debugPrint('Failed to verify user creation for UID: $uid');
        return const Result.failed('Failed to verify user creation');
      }

      try {
        final savedData = savedDoc.data()!;

        // Handle dateOfBirth conversion
        if (savedData['dateOfBirth'] != null) {
          final timestamp = savedData['dateOfBirth'] as Timestamp;
          savedData['dateOfBirth'] = timestamp.toDate();
        }

        final createdUser = User.fromJson(savedData);
        debugPrint('Successfully created user with UID: $uid');
        return Result.success(createdUser);
      } catch (e) {
        debugPrint('Error converting saved data to User object: $e');
        return const Result.failed('Error creating user: Invalid data format');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error creating user: ${e.message}');
      return Result.failed('Failed to create user: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error creating user: $e');
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  // Helper method untuk validasi data
  bool _validateUserData({
    required String email,
    required String name,
  }) {
    if (email.trim().isEmpty || name.trim().isEmpty) {
      debugPrint('Empty email or name');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      debugPrint('Invalid email format: $email');
      return false;
    }

    if (name.trim().length < 2) {
      debugPrint('Name too short');
      return false;
    }

    return true;
  }

  // 2. Mendapatkan semua santri
  @override
  Future<Result<List<User>>> getAllSantri() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firebaseFirestore
              .collection('users')
              .where('role', isEqualTo: 'santri')
              .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success([]);
      }

      List<User> santriList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }
        data['role'] = _stringToUserRole(data['role']);
        return User.fromJson(data);
      }).toList();

      return Result.success(santriList);
    } catch (e) {
      debugPrint('Error getting santri list: $e');
      return Result.failed('Failed to get santri list: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<User>>> getUsersByRole({required UserRole role}) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: role.toString().split('.').last)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }
        data['role'] = _stringToUserRole(data['role']);
        return User.fromJson(data);
      }).toList();

      return Result.success(users);
    } catch (e) {
      debugPrint('Error getting users by role: $e');
      return Result.failed('Failed to get users: ${e.toString()}');
    }
  }

  // 3. Mendapatkan user berdasarkan ID
  @override
  Future<Result<User>> getUser({required String uid}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result =
          await _firebaseFirestore.doc('users/$uid').get();

      if (result.exists) {
        final data = result.data()!;
        debugPrint('Role retrieved from Firestore: ${data['role']}');

        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Pastikan role string sesuai dengan @JsonValue
        data['role'] = _stringToUserRole(data['role'] as String);
        User user = User.fromJson(data);
        return Result.success(user);
      }
      return const Result.failed('User not found');
    } catch (e) {
      debugPrint('Error getting user: $e');
      return Result.failed('Failed to get user: ${e.toString()}');
    }
  }

  // 4. Mendapatkan program yang diikuti user
  @override
  Future<Result<List<String>>> getUserPrograms({required String uid}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (!result.exists) {
        return const Result.failed('User not found');
      }

      // Extract programs array and ensure it's List<String>
      List<String> programs =
          List<String>.from(result.data()?['programs'] ?? []);
      return Result.success(programs);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get user programs');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  // 5. Update data user
  @override
  Future<Result<User>> updateUser({required User user}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/${user.uid}');

      debugPrint('Attempting to update user: ${user.uid}');

      // Get current user data first to check role changes
      DocumentSnapshot<Map<String, dynamic>> currentSnapshot =
          await documentReference.get();

      if (!currentSnapshot.exists) {
        debugPrint('User not found: ${user.uid}');
        return const Result.failed('User not found');
      }

      // Get current user data and convert role
      final currentData = currentSnapshot.data()!;
      final currentRole = _stringToUserRole(currentData['role']);
      debugPrint('Current role: $currentRole, New role: ${user.role}');

      // Convert user to JSON and prepare update data
      final updateData = user.toJson();
      updateData['role'] = _userRoleToString(user.role);

      if (user.dateOfBirth != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(user.dateOfBirth!);
      }
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Prevent role downgrade from superAdmin to lower roles
      if (currentRole == UserRole.superAdmin &&
          user.role != UserRole.superAdmin) {
        debugPrint('Attempted to downgrade superAdmin role');
        return const Result.failed('Cannot downgrade Super Admin role');
      }

      // Update the document
      await documentReference.update(updateData);
      debugPrint('Document updated successfully');

      // Get updated document
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        final data = result.data()!;

        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        data['role'] = _stringToUserRole(data['role']);
        User updatedUser = User.fromJson(data);

        if (updatedUser != user) {
          debugPrint('Update verification failed');
          return const Result.failed('Failed to verify user update');
        }

        debugPrint('User updated successfully');
        return Result.success(updatedUser);
      } else {
        debugPrint('Failed to get updated user data');
        return const Result.failed('Failed to get updated user data');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating user: ${e.message}');
      return Result.failed(e.message ?? 'Failed to update user data');
    } catch (e) {
      debugPrint('Unexpected error updating user: $e');
      return Result.failed(
          'Unexpected error while updating user: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateUserProgram({
    required String uid,
    required String programId,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      // Verify user exists and is a santri
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await documentReference.get();

      if (!userDoc.exists) {
        return const Result.failed('User not found');
      }

      final userData = userDoc.data()!;
      final userRole = _stringToUserRole(userData['role']);

      if (userRole != UserRole.santri) {
        return const Result.failed('Only santri can be added to programs');
      }

      // Update programs array
      await documentReference.update({
        'programs': FieldValue.arrayUnion([programId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Verify update success
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        List<String> programs =
            List<String>.from(result.data()?['programs'] ?? []);
        if (programs.contains(programId)) {
          return const Result.success(null);
        }
      }

      return const Result.failed('Failed to update user program');
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update user program');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  // 7. Upload foto profil
  @override
  Future<Result<User>> uploadProfilePicture({
    required User user,
    required File imageFile,
  }) async {
    try {
      // Validate file existence
      if (!imageFile.existsSync()) {
        return const Result.failed('File not found');
      }

      // Create unique filename using user's uid
      String extension = basename(imageFile.path).split('.').last;
      String filename = 'profile_pictures/${user.uid}.$extension';

      // Get storage reference
      Reference reference = FirebaseStorage.instance.ref().child(filename);

      // Upload file
      await reference.putFile(imageFile);

      // Get download URL
      String downloadUrl = await reference.getDownloadURL();

      // Update user with new photo URL
      final updatedUser = user.copyWith(photoUrl: downloadUrl);

      // Use updateUser to save changes
      final updateResult = await updateUser(user: updatedUser);

      if (updateResult.isSuccess) {
        return Result.success(updateResult.resultValue!);
      } else {
        // Try to delete uploaded image if user update fails
        try {
          await reference.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
        return Result.failed(updateResult.errorMessage!);
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to upload profile picture');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return const Result.failed('Email tidak boleh kosong');
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return const Result.failed('Format email tidak valid');
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return const Result.failed('Email tidak ditemukan');
        default:
          return Result.failed(
              e.message ?? 'Gagal mengirim email reset password');
      }
    } catch (e) {
      return Result.failed('Kesalahan tidak terduga: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<User>>> getSantriByProgramId(String programId) async {
    try {
      // Ambil semua user dengan role santri yang mengikuti program ini
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: 'santri')
          .where('programs', arrayContains: programId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final santriList =
            querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
        return Result.success(santriList);
      } else {
        return const Result.success(
            []); // Return empty list jika tidak ada santri
      }
    } catch (e) {
      return Result.failed('Failed to get santri list: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      // Get user data first to check role
      DocumentReference<Map<String, dynamic>> userRef =
          _firebaseFirestore.doc('users/$uid');

      DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

      if (!userDoc.exists) {
        return const Result.failed('User not found');
      }

      // Check if user is superAdmin
      final userRole = _stringToUserRole(userDoc.data()!['role']);
      if (userRole == UserRole.superAdmin) {
        return const Result.failed('Cannot delete Super Admin user');
      }

      // Delete user profile picture if exists
      final photoUrl = userDoc.data()!['photoUrl'] as String?;
      if (photoUrl != null) {
        try {
          final photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
          await photoRef.delete();
        } catch (_) {
          // Continue deletion even if photo deletion fails
        }
      }

      // Delete user document
      await userRef.delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete user');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> removeUserFromProgram({
    required String uid,
    required String programId,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> userRef =
          _firebaseFirestore.doc('users/$uid');

      DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

      if (!userDoc.exists) {
        return const Result.failed('User not found');
      }

      // Check if user is in program
      List<String> programs =
          List<String>.from(userDoc.data()!['programs'] ?? []);
      if (!programs.contains(programId)) {
        return const Result.failed('User is not enrolled in this program');
      }

      // Remove from program
      await userRef.update({
        'programs': FieldValue.arrayRemove([programId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to remove user from program');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }
}
