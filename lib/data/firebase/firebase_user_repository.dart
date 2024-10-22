import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  FirebaseUserRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  // 1. Membuat user baru
  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String role,
    String? photoUrl,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> users =
          _firebaseFirestore.collection('users');

      // Sesuaikan dengan struktur User entity
      await users.doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'photoUrl': photoUrl,
        'phoneNumber': null,
        'dateOfBirth': null,
        'address': null,
      });

      DocumentSnapshot<Map<String, dynamic>> result =
          await users.doc(uid).get();

      if (result.exists) {
        return Result.success(User.fromJson(result.data()!));
      } else {
        return const Result.failed('Failed to create user');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create user');
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
}
