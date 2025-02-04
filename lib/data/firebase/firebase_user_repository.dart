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

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String role,
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

      // Validasi role
      if (!User.isValidRole(role)) {
        debugPrint('Invalid role provided: $role');
        return const Result.failed('Invalid role value');
      }

      final userData = {
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'role': role,
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
              .where('role',
                  isEqualTo: 'santri') // Langsung menggunakan string 'santri'
              .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No santri found in database');
        return const Result.success([]);
      }

      List<User> santriList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Handle date conversion
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Validasi role untuk keamanan
        if (!User.isValidRole(data['role'])) {
          debugPrint('Invalid role found for user: ${doc.id}');
          throw const FormatException('Invalid role in database');
        }

        return User.fromJson(data);
      }).toList();

      debugPrint('Successfully retrieved ${santriList.length} santri');
      return Result.success(santriList);
    } catch (e) {
      debugPrint('Error getting santri list: $e');
      return Result.failed('Failed to get santri list: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<User>>> getUsersByRole({required String role}) async {
    try {
      // Validasi role
      if (!User.isValidRole(role)) {
        debugPrint('Invalid role parameter provided: $role');
        return const Result.failed('Invalid role value');
      }

      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();

        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        return User.fromJson(data);
      }).toList();

      debugPrint('Retrieved ${users.length} users with role: $role');
      return Result.success(users);
    } catch (e) {
      debugPrint('Error getting users by role: $e');
      return Result.failed('Failed to get users: ${e.toString()}');
    }
  }

  @override
  Future<Result<User>> getUser({required String uid}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result =
          await _firebaseFirestore.doc('users/$uid').get();

      if (result.exists) {
        final data = result.data()!;
        debugPrint('Role retrieved from Firestore: ${data['role']}');

        // Validasi role
        if (!User.isValidRole(data['role'])) {
          debugPrint('Invalid role found in database: ${data['role']}');
          return const Result.failed('Invalid role data in database');
        }

        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

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

      // Get current user data and validate new role
      final currentData = currentSnapshot.data()!;
      final currentRole = currentData['role'] as String;

      debugPrint('Current role: $currentRole, New role: ${user.role}');

      // Validate new role
      if (!User.isValidRole(user.role)) {
        debugPrint('Invalid new role provided: ${user.role}');
        return const Result.failed('Invalid role value');
      }

      // Convert user to JSON and prepare update data
      final updateData = user.toJson();

      if (user.dateOfBirth != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(user.dateOfBirth!);
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Prevent role downgrade from superAdmin to lower roles
      if (currentRole == 'superAdmin' && user.role != 'superAdmin') {
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
        debugPrint('User not found: $uid');
        return const Result.failed('User not found');
      }

      final userData = userDoc.data()!;
      final userRole = userData['role'] as String; // Langsung ambil string role

      if (userRole != 'santri') {
        // Langsung bandingkan string
        debugPrint('Non-santri user attempted to join program: $uid');
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
          debugPrint('Successfully added user $uid to program $programId');
          return const Result.success(null);
        }
      }

      debugPrint('Failed to verify program update for user $uid');
      return const Result.failed('Failed to update user program');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating user program: ${e.message}');
      return Result.failed(e.message ?? 'Failed to update user program');
    } catch (e) {
      debugPrint('Unexpected error: $e');
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
        debugPrint('Profile picture file not found');
        return const Result.failed('File not found');
      }

      // Create unique filename using user's uid
      String extension = basename(imageFile.path).split('.').last;
      String filename = 'profile_pictures/${user.uid}.$extension';

      // Get storage reference
      Reference reference = FirebaseStorage.instance.ref().child(filename);

      // Upload file
      await reference.putFile(imageFile);
      debugPrint('Profile picture uploaded successfully');

      // Get download URL
      String downloadUrl = await reference.getDownloadURL();
      debugPrint('Got download URL: $downloadUrl');

      // Update user with new photo URL
      final updatedUser = user.copyWith(photoUrl: downloadUrl);

      // Use updateUser to save changes
      final updateResult = await updateUser(user: updatedUser);

      if (updateResult.isSuccess) {
        debugPrint('User profile picture updated successfully');
        return Result.success(updateResult.resultValue!);
      } else {
        // Try to delete uploaded image if user update fails
        try {
          await reference.delete();
          debugPrint('Cleaned up uploaded image after failed update');
        } catch (_) {
          debugPrint('Failed to cleanup uploaded image');
        }
        return Result.failed(updateResult.errorMessage!);
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading profile picture: ${e.message}');
      return Result.failed(e.message ?? 'Failed to upload profile picture');
    } catch (e) {
      debugPrint('Unexpected error: $e');
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
      debugPrint('Password reset email sent to: $email');
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error on password reset: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return const Result.failed('Email tidak ditemukan');
        default:
          return Result.failed(
              e.message ?? 'Gagal mengirim email reset password');
      }
    } catch (e) {
      debugPrint('Error in reset password: $e');
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
      final userRole = userDoc.data()!['role'] as String;
      if (userRole == 'superAdmin') {
        debugPrint('Attempted to delete superAdmin account');
        return const Result.failed('Cannot delete Super Admin user');
      }

      // Delete user profile picture if exists
      final photoUrl = userDoc.data()!['photoUrl'] as String?;
      if (photoUrl != null) {
        try {
          final photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
          await photoRef.delete();
          debugPrint('Deleted user profile picture');
        } catch (e) {
          // Continue deletion even if photo deletion fails
          debugPrint('Failed to delete profile picture: $e');
        }
      }

      // Delete user document
      await userRef.delete();
      debugPrint('Successfully deleted user: $uid');

      return const Result.success(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting user: ${e.message}');
      return Result.failed(e.message ?? 'Failed to delete user');
    } catch (e) {
      debugPrint('Unexpected error deleting user: $e');
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
        debugPrint('User not found: $uid');
        return const Result.failed('User not found');
      }

      // Check if user is in program
      List<String> programs =
          List<String>.from(userDoc.data()!['programs'] ?? []);

      if (!programs.contains(programId)) {
        debugPrint('User is not enrolled in program: $programId');
        return const Result.failed('User is not enrolled in this program');
      }

      // Remove from program
      await userRef.update({
        'programs': FieldValue.arrayRemove([programId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Successfully removed user $uid from program $programId');
      return const Result.success(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error removing user from program: ${e.message}');
      return Result.failed(e.message ?? 'Failed to remove user from program');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }
}
