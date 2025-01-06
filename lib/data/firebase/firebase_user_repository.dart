import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  FirebaseUserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  // Helper method untuk konversi UserRole ke String
  String _userRoleToString(UserRole role) {
    return role.toString().split('.').last;
  }

  // Helper method untuk konversi String ke UserRole
  UserRole _stringToUserRole(String roleStr) {
    return UserRole.values.firstWhere(
      (role) => role.toString().split('.').last == roleStr,
      orElse: () => UserRole.santri, // Default ke santri jika tidak valid
    );
  }

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          _firebaseFirestore.collection('users');

      // Validasi field required
      if (email.isEmpty || name.isEmpty) {
        return const Result.failed('Required fields cannot be empty');
      }

      // Buat user data dengan role default SANTRI
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'role': _userRoleToString(UserRole.santri), // Default role SANTRI
        'isActive': true, // Default active
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        'address': address,
        'programs': [], // Array kosong untuk daftar program
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create user document
      await users.doc(uid).set(userData);

      // Get created user
      DocumentSnapshot<Map<String, dynamic>> result =
          await users.doc(uid).get();

      if (result.exists) {
        final data = result.data()!;

        // Convert Timestamp to DateTime
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Convert role string to enum
        data['role'] = _stringToUserRole(data['role']);

        return Result.success(User.fromJson(data));
      } else {
        return const Result.failed('Failed to create user');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create user');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  // 2. Mendapatkan semua santri
  @override
  Future<Result<List<User>>> getAllSantri() async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          _firebaseFirestore.collection('users');

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await users
          .where('role', isEqualTo: _userRoleToString(UserRole.santri))
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success([]);
      }

      List<User> santriList = querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Convert Timestamp to DateTime if exists
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Role already filtered as santri
        data['role'] = UserRole.santri;

        return User.fromJson(data);
      }).toList();

      return Result.success(santriList);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get santri list');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<User>>> getUsersByRole({required UserRole role}) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: _userRoleToString(role))
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success([]); // Return empty list if no users found
      }

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Convert Timestamp to DateTime if exists
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Convert role string to enum
        data['role'] = _stringToUserRole(data['role']);

        return User.fromJson(data);
      }).toList();

      return Result.success(users);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get users by role');
    } catch (e) {
      return Result.failed('Failed to get users by role: ${e.toString()}');
    }
  }

  // 3. Mendapatkan user berdasarkan ID
  @override
  Future<Result<User>> getUser({required String uid}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        final data = result.data()!;

        // Convert Timestamp to DateTime if exists
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Convert role string to enum
        data['role'] = _stringToUserRole(data['role']);

        User user = User.fromJson(data);
        return Result.success(user);
      } else {
        return const Result.failed('User not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get user data');
    } catch (e) {
      return Result.failed('Unexpected error: ${e.toString()}');
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

      // Get current user data first to check role changes
      DocumentSnapshot<Map<String, dynamic>> currentSnapshot =
          await documentReference.get();

      if (!currentSnapshot.exists) {
        return const Result.failed('User not found');
      }

      // Get current user data and convert role
      final currentData = currentSnapshot.data()!;
      final currentRole = _stringToUserRole(currentData['role']);

      // Convert user to JSON and prepare update data
      final updateData = user.toJson();

      // Convert role to string for storage
      updateData['role'] = _userRoleToString(user.role);

      // Convert DateTime to Timestamp for dateOfBirth if exists
      if (user.dateOfBirth != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(user.dateOfBirth!);
      }

      // Add update timestamp
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Prevent role downgrade from superAdmin to lower roles
      if (currentRole == UserRole.superAdmin &&
          user.role != UserRole.superAdmin) {
        return const Result.failed('Cannot downgrade Super Admin role');
      }

      // Update the document
      await documentReference.update(updateData);

      // Get updated document
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        final data = result.data()!;

        // Convert Timestamp back to DateTime if exists
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }

        // Convert role string back to enum
        data['role'] = _stringToUserRole(data['role']);

        User updatedUser = User.fromJson(data);

        // Verify update was successful
        if (updatedUser != user) {
          return const Result.failed('Failed to verify user update');
        }

        return Result.success(updatedUser);
      } else {
        return const Result.failed('Failed to get updated user data');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update user data');
    } catch (e) {
      return Result.failed(
          'Unexpected error while updating user: ${e.toString()}');
    }
  }

  // Other methods will be implemented next...

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
