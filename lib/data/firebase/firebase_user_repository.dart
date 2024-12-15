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
      CollectionReference<Map<String, dynamic>> users =
          _firebaseFirestore.collection('users');

      // Tambahkan validasi
      if (email.isEmpty || name.isEmpty || role.isEmpty) {
        return const Result.failed('Required fields cannot be empty');
      }

      // Sesuaikan dengan struktur User entity dengan tambahan field
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        'address': address,
        'programs': [], // Array kosong untuk daftar program yang diikuti
        'createdAt': FieldValue.serverTimestamp(), // Waktu pembuatan user
        'updatedAt': FieldValue.serverTimestamp(), // Waktu update terakhir
      };

      await users.doc(uid).set(userData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await users.doc(uid).get();

      if (result.exists) {
        // Konversi Timestamp ke DateTime saat membuat User object
        final data = result.data()!;
        if (data['dateOfBirth'] != null) {
          final timestamp = data['dateOfBirth'] as Timestamp;
          data['dateOfBirth'] = timestamp.toDate();
        }
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

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await users.where('role', isEqualTo: 'santri').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<User> santriList =
            querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
        return Result.success(santriList);
      } else {
        return const Result.failed('No santri found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get santri list');
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
        User user = User.fromJson(result.data()!);
        return Result.success(user);
      } else {
        return const Result.failed('User not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get user data');
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

      if (result.exists) {
        List<String> programs =
            List<String>.from(result.data()?['programs'] ?? []);
        return Result.success(programs);
      } else {
        return const Result.failed('User not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get user programs');
    }
  }

  // 5. Update data user
  @override
  Future<Result<User>> updateUser({required User user}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/${user.uid}');
      await documentReference.update(user.toJson());

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        User updatedUser = User.fromJson(result.data()!);
        if (updatedUser == user) {
          return Result.success(updatedUser);
        } else {
          return const Result.failed('Failed to update user data');
        }
      } else {
        return const Result.failed('Failed to update user data');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update user data');
    }
  }

  @override
  Future<Result<void>> updateUserProgram(
      {required String uid, required String programId}) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      await documentReference.update({
        'programs': FieldValue.arrayUnion([programId])
      });

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        List<String> programs =
            List<String>.from(result.data()?['programs'] ?? []);

        if (programs.contains(programId)) {
          return const Result.success(null);
        } else {
          return const Result.failed('Failed to update user program');
        }
      } else {
        return const Result.failed('User not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update user program');
    }
  }

  // 7. Upload foto profil
  @override
  Future<Result<User>> uploadProfilePicture(
      {required User user, required File imageFile}) async {
    try {
      // Buat nama file yang unik dengan uid user
      String extension = basename(imageFile.path).split('.').last;
      String filename = 'profile_pictures/${user.uid}.$extension';

      // Get reference ke Firebase Storage
      Reference reference = FirebaseStorage.instance.ref().child(filename);

      // Upload file
      await reference.putFile(imageFile);

      // Dapatkan URL download
      String downloadUrl = await reference.getDownloadURL();

      // Update user dengan URL foto baru
      var updateResult =
          await updateUser(user: user.copyWith(photoUrl: downloadUrl));

      if (updateResult.isSuccess) {
        return Result.success(updateResult.resultValue!);
      } else {
        return Result.failed(updateResult.errorMessage!);
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to upload profile picture');
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
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
      await _firebaseFirestore.collection('users').doc(uid).delete();
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete user');
    }
  }

  @override
  Future<Result<void>> removeUserFromProgram({
    required String uid,
    required String programId,
  }) async {
    try {
      await _firebaseFirestore.collection('users').doc(uid).update({
        'programs': FieldValue.arrayRemove([programId])
      });
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to remove user from program');
    }
  }

  @override
  Future<Result<List<User>>> getUsersByRole({required String role}) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      final users =
          querySnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();

      return Result.success(users);
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get users by role');
    }
  }
}
