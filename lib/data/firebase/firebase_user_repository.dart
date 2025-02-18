import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../repositories/user_repository.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/user.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _storage;

  FirebaseUserRepository({
    FirebaseFirestore? firebaseFirestore,
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? storage,
  })  : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
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
  }) async {
    try {
      // 1. Verifikasi state auth
      final authUser = _firebaseAuth.currentUser;
      if (authUser == null) {
        debugPrint('No authenticated user found during profile creation');
        return const Result.failed('Authentication error during registration');
      }

      // 2. Verifikasi UID match
      if (authUser.uid != uid) {
        debugPrint('UID mismatch between Auth and request');
        return const Result.failed('Authentication validation failed');
      }

      // 3. Validasi data dasar
      final validationError = _validateUserData(
        uid: uid,
        email: email,
        name: name,
        role: role,
        selectedPrograms: selectedPrograms,
      );
      if (validationError != null) {
        debugPrint('Basic data validation failed: $validationError');
        return Result.failed(validationError);
      }

      if (role == 'santri') {
        final programValidation = _validateSantriPrograms(selectedPrograms);
        if (programValidation != null) {
          debugPrint('Program validation failed: $programValidation');
          return Result.failed(programValidation);
        }
      }

      // 4. Persiapkan data user dengan konversi timestamp yang benar
      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'role': role,
        'isActive': true,
        'programs': selectedPrograms,
        'photoUrl': photoUrl?.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'address': address?.trim(),
        'dateOfBirth':
            dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 5. Remove null values
      userData.removeWhere((key, value) => value == null);

      // 6. Get document reference
      final userRef = _firebaseFirestore.collection('users').doc(uid);

      // 7. Gunakan transaction untuk atomic write
      await _firebaseFirestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        // Jika document sudah ada, update data
        if (userDoc.exists) {
          transaction.update(userRef, {
            ...userData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Jika belum ada, buat document baru
          transaction.set(userRef, userData);
        }
      });

      // 8. Verifikasi data tersimpan
      final savedDoc = await userRef.get();
      if (!savedDoc.exists) {
        debugPrint('Failed to verify user document creation');
        // Cleanup jika verifikasi gagal
        await _cleanupFailedRegistration(uid);
        return const Result.failed('Failed to verify user creation');
      }

      // 9. Kirim email verifikasi jika belum terverifikasi
      if (!authUser.emailVerified) {
        try {
          await authUser.sendEmailVerification();
          debugPrint('Verification email sent to: $email');
        } catch (e) {
          debugPrint('Failed to send verification email: $e');
          // Continue execution even if email verification fails
        }
      }

      // 10. Return User entity dengan konversi timestamp yang benar
      return Result.success(User.fromJson({
        ...savedDoc.data()!,
        'dateOfBirth': _convertTimestamp(savedDoc.data()!['dateOfBirth'])
            ?.toIso8601String(),
        'createdAt':
            _convertTimestamp(savedDoc.data()!['createdAt'])?.toIso8601String(),
        'updatedAt':
            _convertTimestamp(savedDoc.data()!['updatedAt'])?.toIso8601String(),
      }));
    } on FirebaseException catch (e) {
      debugPrint('Firebase error creating user: ${e.message}');
      await _cleanupFailedRegistration(uid);
      return Result.failed('Failed to create user: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error creating user: $e');
      await _cleanupFailedRegistration(uid);
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

  Future<bool> _verifyUserInAuth(String email) async {
    try {
      // Gunakan error handling untuk verifikasi
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporary-password',
      );
      return false; // User belum ada
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true; // User sudah ada
      }
      return false;
    } catch (e) {
      return false;
    }
  }

// Helper untuk cleanup saat registrasi gagal
  Future<void> _cleanupFailedRegistration(String uid) async {
    try {
      // 1. Delete Firestore document jika ada
      final userRef = _firebaseFirestore.collection('users').doc(uid);
      final docSnapshot = await userRef.get();
      if (docSnapshot.exists) {
        await userRef.delete();
      }

      // 2. Delete user dari Authentication jika masih ada
      final authUser = _firebaseAuth.currentUser;
      if (authUser?.uid == uid) {
        await authUser?.delete();
      }

      // 3. Sign out untuk membersihkan state
      await _firebaseAuth.signOut();

      debugPrint('Cleanup completed for failed registration: $uid');
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  // Helper method untuk konversi Timestamp <-> DateTime
  DateTime? _convertTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  // Helper untuk validasi data user
  String? _validateUserData({
    required String uid,
    required String email,
    required String name,
    required String role,
    required List<String> selectedPrograms,
  }) {
    if (uid.isEmpty) return 'UID tidak boleh kosong';
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (name.isEmpty) return 'Nama tidak boleh kosong';
    if (!User.isValidRole(role)) return 'Role tidak valid';
    if (role == 'santri' && selectedPrograms.isEmpty) {
      return 'Santri harus memilih minimal 1 program';
    }
    return null;
  }

  // Helper untuk validasi program santri
  String? _validateSantriPrograms(List<String> programs) {
    if (programs.isEmpty) {
      return 'Santri harus memilih minimal 1 program';
    }

    if (programs.length > 3) {
      return 'Maksimal pilih 3 program';
    }

    if (!User.areValidPrograms(programs)) {
      return 'Program yang dipilih tidak valid';
    }

    // Check untuk program yang tidak bisa diambil bersamaan
    if (programs.contains('GMM') && programs.contains('IFIS')) {
      return 'Program GMM dan IFIS tidak dapat diambil bersamaan';
    }

    return null;
  }

  // 2. Mendapatkan semua santri
  @override
  Future<Result<List<User>>> getAllSantri() async {
    try {
      // 1. Query untuk mendapatkan semua santri
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firebaseFirestore
              .collection('users')
              .where('role', isEqualTo: 'santri')
              .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No santri found in database');
        return const Result.success(
            []); // Return empty list jika tidak ada data
      }

      List<User> santriList = [];

      // 2. Iterasi dan konversi data
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // 3. Konversi data dengan proper error handling
          final convertedData = {
            ...data,
            'dateOfBirth':
                _convertTimestamp(data['dateOfBirth'])?.toIso8601String(),
            'createdAt':
                _convertTimestamp(data['createdAt'])?.toIso8601String(),
            'updatedAt':
                _convertTimestamp(data['updatedAt'])?.toIso8601String(),
          };

          // 4. Validasi role untuk keamanan
          if (!User.isValidRole(convertedData['role'])) {
            debugPrint('Invalid role found for user: ${doc.id}');
            continue; // Skip invalid data
          }

          // 5. Validasi programs untuk santri
          final programs = List<String>.from(data['programs'] ?? []);
          if (programs.isEmpty) {
            debugPrint('Santri ${doc.id} has no programs');
            continue; // Skip santri tanpa program
          }

          // 6. Buat User entity
          final santri = User.fromJson(convertedData);

          // 7. Pastikan user aktif di Authentication
          try {
            await _firebaseAuth.fetchSignInMethodsForEmail(santri.email);
            santriList.add(santri);
          } catch (e) {
            debugPrint('User ${santri.email} not found in Authentication: $e');
            // Optional: Bisa ditambahkan logic untuk cleanup atau marking user
          }
        } catch (e) {
          debugPrint('Error converting santri data for ID ${doc.id}: $e');
          continue; // Skip data yang error
        }
      }

      debugPrint('Successfully retrieved ${santriList.length} santri');
      return Result.success(santriList);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting santri list: ${e.message}');
      return Result.failed('Failed to get santri list: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error getting santri list: $e');
      return Result.failed('Failed to get santri list: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<User>>> getUsersByRole({required String role}) async {
    try {
      // 1. Validasi role
      if (!User.isValidRole(role)) {
        debugPrint('Invalid role parameter provided: $role');
        return const Result.failed('Invalid role value');
      }

      // 2. Query users dengan role tertentu
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      List<User> users = [];
      List<String> authErrors = [];

      // 3. Process setiap user
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // 4. Konversi timestamp dengan proper handling
          final convertedData = {
            ...data,
            'dateOfBirth':
                _convertTimestamp(data['dateOfBirth'])?.toIso8601String(),
            'createdAt':
                _convertTimestamp(data['createdAt'])?.toIso8601String(),
            'updatedAt':
                _convertTimestamp(data['updatedAt'])?.toIso8601String(),
          };

          // 5. Create User entity
          final user = User.fromJson(convertedData);

          // 6. Verifikasi user di Authentication
          try {
            final signInMethods =
                await _firebaseAuth.fetchSignInMethodsForEmail(user.email);

            if (signInMethods.isNotEmpty) {
              // User exists in Authentication
              users.add(user);
            } else {
              authErrors.add('User ${user.email} not found in Authentication');

              // Optional: Attempt to recreate auth user if needed
              if (role != 'superAdmin') {
                await _attemptAuthRecovery(user);
              }
            }
          } catch (authError) {
            debugPrint(
                'Authentication verification failed for ${user.email}: $authError');
            authErrors.add('Auth error for ${user.email}: $authError');
          }
        } catch (e) {
          debugPrint('Error processing user document ${doc.id}: $e');
          continue; // Skip invalid data
        }
      }

      // 7. Log authentication errors if any
      if (authErrors.isNotEmpty) {
        debugPrint('Authentication issues found:');
        for (var error in authErrors) {
          debugPrint('- $error');
        }
      }

      debugPrint('Retrieved ${users.length} users with role: $role');
      return Result.success(users);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting users: ${e.message}');
      return Result.failed('Failed to get users: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error getting users: $e');
      return Result.failed('Failed to get users: ${e.toString()}');
    }
  }

  // Helper untuk mencoba recovery authentication user
  Future<void> _attemptAuthRecovery(User user) async {
    try {
      // Check if user should have auth account
      if (!user.isActive) return;

      debugPrint('Attempting auth recovery for user: ${user.email}');

      // Bisa ditambahkan logic untuk:
      // 1. Create auth user
      // 2. Send password reset email
      // 3. Update status di Firestore
      // 4. Notify admin
    } catch (e) {
      debugPrint('Auth recovery failed for ${user.email}: $e');
    }
  }

  @override
  Future<Result<User>> getUser({required String uid}) async {
    try {
      // 1. Validasi parameter
      if (uid.isEmpty) {
        debugPrint('Empty UID provided');
        return const Result.failed('User ID cannot be empty');
      }

      // 2. Ambil data dari Firestore
      DocumentSnapshot<Map<String, dynamic>> result =
          await _firebaseFirestore.doc('users/$uid').get();

      if (!result.exists) {
        debugPrint('User document not found: $uid');
        return Result.failed('User with ID: $uid not found');
      }

      final data = result.data()!;
      debugPrint('Role retrieved from Firestore: ${data['role']}');

      // 3. Validasi role
      if (!User.isValidRole(data['role'])) {
        debugPrint('Invalid role found in database: ${data['role']}');
        return const Result.failed('Invalid role data in database');
      }

      // 4. Verifikasi user di Authentication
      try {
        final authUser =
            await _firebaseAuth.fetchSignInMethodsForEmail(data['email']);
        if (authUser.isEmpty && data['isActive'] == true) {
          debugPrint(
              'Warning: Active user not found in Authentication: ${data['email']}');
          // Optional: Trigger auth recovery process
          await _handleMissingAuthUserData(data);
        }
      } catch (authError) {
        debugPrint('Authentication verification failed: $authError');
        // Continue execution as we still want to return the user data
      }

      // 5. Konversi data dengan proper timestamp handling
      final convertedData = {
        ...data,
        'dateOfBirth':
            _convertTimestamp(data['dateOfBirth'])?.toIso8601String(),
        'createdAt': _convertTimestamp(data['createdAt'])?.toIso8601String(),
        'updatedAt': _convertTimestamp(data['updatedAt'])?.toIso8601String(),
      };

      // 6. Validasi programs untuk santri
      if (data['role'] == 'santri') {
        final programs = List<String>.from(data['programs'] ?? []);
        if (programs.isEmpty) {
          debugPrint('Warning: Santri has no programs: $uid');
        }
      }

      // 7. Create dan return User entity
      User user = User.fromJson(convertedData);
      return Result.success(user);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting user: ${e.message}');
      return Result.failed('Failed to get user: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error getting user: $e');
      return Result.failed('Failed to get user: ${e.toString()}');
    }
  }

// Helper untuk menangani kasus user tidak ada di Authentication
  Future<void> _handleMissingAuthUserData(Map<String, dynamic> userData) async {
    try {
      debugPrint('Handling missing auth user for: ${userData['email']}');

      // Record issue untuk monitoring
      await _firebaseFirestore.collection('auth_issues').add({
        'uid': userData['uid'],
        'email': userData['email'],
        'type': 'missing_auth_user',
        'timestamp': FieldValue.serverTimestamp(),
        'userData': userData,
      });
    } catch (e) {
      debugPrint('Error handling missing auth user: $e');
    }
  }

  // 4. Mendapatkan program yang diikuti user
  @override
  Future<Result<List<String>>> getUserPrograms({required String uid}) async {
    try {
      // 1. Validasi parameter
      if (uid.isEmpty) {
        debugPrint('Empty UID provided');
        return const Result.failed('User ID cannot be empty');
      }

      // 2. Get user document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      // 3. Get user data dengan error handling
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (!result.exists) {
        debugPrint('User document not found: $uid');
        return const Result.failed('User not found');
      }

      final userData = result.data()!;

      // 4. Verifikasi user di Authentication
      try {
        final authUser =
            await _firebaseAuth.fetchSignInMethodsForEmail(userData['email']);
        if (authUser.isEmpty) {
          debugPrint(
              'Warning: User not found in Authentication: ${userData['email']}');
          if (userData['isActive'] == true) {
            await _handleAuthenticationIssue(uid, userData['email']);
          }
        }
      } catch (authError) {
        debugPrint('Authentication verification failed: $authError');
        // Continue execution as we still want to return the program data
      }

      // 5. Extract dan validasi programs
      List<String> programs = [];
      if (userData.containsKey('programs')) {
        programs = List<String>.from(userData['programs'] ?? []);

        // 6. Validasi setiap program
        programs = programs.where((program) {
          bool isValid = _isValidProgram(program);
          if (!isValid) {
            debugPrint('Invalid program found: $program for user: $uid');
          }
          return isValid;
        }).toList();
      }

      // 7. Validasi khusus untuk santri
      if (userData['role'] == 'santri' && programs.isEmpty) {
        debugPrint('Warning: Santri has no programs: $uid');
        // Optional: Bisa ditambahkan notifikasi ke admin
      }

      debugPrint('Retrieved ${programs.length} programs for user: $uid');
      return Result.success(programs);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting user programs: ${e.message}');
      return Result.failed(e.message ?? 'Failed to get user programs');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Result.failed('Unexpected error: ${e.toString()}');
    }
  }

// Helper untuk validasi program
  bool _isValidProgram(String program) {
    final validPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
    return validPrograms.contains(program.toUpperCase());
  }

  Future<void> _handleAuthenticationIssue(String uid, String email) async {
    try {
      debugPrint('Recording authentication issue for user: $uid');

      // Record issue untuk monitoring
      await _firebaseFirestore.collection('auth_issues').add({
        'uid': uid,
        'email': email,
        'type': 'missing_auth_user_programs',
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'User exists in Firestore but not in Authentication'
      });

      // Update user status di Firestore
      await _firebaseFirestore.doc('users/$uid').update({
        'authIssueDetected': true,
        'authIssueTimestamp': FieldValue.serverTimestamp()
      });
    } catch (e) {
      debugPrint('Error handling authentication issue: $e');
    }
  }

  // 5. Update data user
  @override
  Future<Result<User>> updateUser({required User user}) async {
    try {
      // 1. Validasi user ID
      if (user.uid.isEmpty) {
        debugPrint('Empty UID provided');
        return const Result.failed('User ID cannot be empty');
      }

      // 2. Get document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/${user.uid}');

      // 3. Verify existing user
      final currentSnapshot = await documentReference.get();
      if (!currentSnapshot.exists) {
        debugPrint('User not found: ${user.uid}');
        return const Result.failed('User not found');
      }

      // 4. Get current user data dan validasi role changes
      final currentData = currentSnapshot.data()!;
      final currentRole = currentData['role'] as String;
      debugPrint('Current role: $currentRole, New role: ${user.role}');

      // 5. Verifikasi user di Authentication
      try {
        final authMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(user.email);
        if (authMethods.isEmpty) {
          debugPrint(
              'Warning: User not found in Authentication: ${user.email}');
          await _handleMissingAuthUserUpdate(user);
          return const Result.failed('User not found in Authentication system');
        }
      } catch (authError) {
        debugPrint('Authentication verification failed: $authError');
        return Result.failed(
            'Authentication verification failed: ${authError.toString()}');
      }

      // 6. Validasi perubahan role
      if (!User.isValidRole(user.role)) {
        debugPrint('Invalid new role provided: ${user.role}');
        return const Result.failed('Invalid role value');
      }

      // 7. Prevent role downgrade from superAdmin
      if (currentRole == 'superAdmin' && user.role != 'superAdmin') {
        debugPrint('Attempted to downgrade superAdmin role');
        return const Result.failed('Cannot downgrade Super Admin role');
      }

      // 8. Prepare update data dengan proper timestamp handling
      final updateData = {
        ...user.toJson(),
        'dateOfBirth': user.dateOfBirth != null
            ? Timestamp.fromDate(user.dateOfBirth!)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 9. Remove fields yang tidak boleh diupdate
      updateData.remove('uid');
      updateData.remove('createdAt');

      // 10. Update dalam transaction untuk atomic operation
      await _firebaseFirestore.runTransaction((transaction) async {
        // Verifikasi ulang document sebelum update
        final freshDoc = await transaction.get(documentReference);
        if (!freshDoc.exists) {
          throw Exception('User document no longer exists');
        }

        // Perform update
        transaction.update(documentReference, updateData);
      });

      // 11. Get dan verify updated data
      final updatedDoc = await documentReference.get();
      if (!updatedDoc.exists) {
        debugPrint('Failed to verify update: Document not found');
        return const Result.failed('Failed to verify user update');
      }

      final data = updatedDoc.data()!;

      // 12. Convert timestamps dan create User entity
      final updatedUser = User.fromJson({
        ...data,
        'dateOfBirth':
            _convertTimestamp(data['dateOfBirth'])?.toIso8601String(),
        'createdAt': _convertTimestamp(data['createdAt'])?.toIso8601String(),
        'updatedAt': _convertTimestamp(data['updatedAt'])?.toIso8601String(),
      });

      // 13. Validasi hasil update
      if (!_validateUpdatedUser(user, updatedUser)) {
        debugPrint('Update verification failed: Data mismatch');
        return const Result.failed('Failed to verify user update');
      }

      debugPrint('User updated successfully: ${user.uid}');
      return Result.success(updatedUser);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating user: ${e.message}');
      return Result.failed(e.message ?? 'Failed to update user data');
    } catch (e) {
      debugPrint('Unexpected error updating user: $e');
      return Result.failed(
          'Unexpected error while updating user: ${e.toString()}');
    }
  }

// Helper untuk menangani kasus user tidak ada di Authentication
  Future<void> _handleMissingAuthUserUpdate(User user) async {
    try {
      debugPrint('Recording missing auth user: ${user.email}');

      await _firebaseFirestore.collection('auth_issues').add({
        'uid': user.uid,
        'email': user.email,
        'type': 'missing_auth_user_update',
        'timestamp': FieldValue.serverTimestamp(),
        'attemptedUpdate': user.toJson()
      });
    } catch (e) {
      debugPrint('Error recording auth issue: $e');
    }
  }

// Helper untuk validasi hasil update
  bool _validateUpdatedUser(User original, User updated) {
    // Validasi field-field penting
    return original.uid == updated.uid &&
        original.email == updated.email &&
        original.role == updated.role &&
        original.name == updated.name;
  }

  @override
  Future<Result<void>> updateUserProgram({
    required String uid,
    required String programId,
  }) async {
    try {
      // 1. Validasi parameter
      if (uid.isEmpty || programId.isEmpty) {
        debugPrint('Invalid parameters - UID: $uid, ProgramID: $programId');
        return const Result.failed('Invalid parameters provided');
      }

      // 2. Get document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firebaseFirestore.doc('users/$uid');

      // 3. Verify user exists dan validasi role
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await documentReference.get();
      if (!userDoc.exists) {
        debugPrint('User not found: $uid');
        return const Result.failed('User not found');
      }

      final userData = userDoc.data()!;
      final userRole = userData['role'] as String;

      // 4. Validasi role santri
      if (userRole != 'santri') {
        debugPrint('Non-santri user attempted to join program: $uid');
        return const Result.failed('Only santri can be added to programs');
      }

      // 5. Verifikasi user di Authentication
      try {
        final authMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(userData['email']);
        if (authMethods.isEmpty) {
          debugPrint('User not found in Authentication: ${userData['email']}');
          return const Result.failed('User authentication issue detected');
        }
      } catch (authError) {
        debugPrint('Authentication verification failed: $authError');
        return Result.failed(
            'Authentication verification failed: ${authError.toString()}');
      }

      // 6. Validasi program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(programId)) {
        debugPrint('Invalid program ID: $programId');
        return const Result.failed('Invalid program ID');
      }

      // 7. Update program dengan transaction
      await _firebaseFirestore.runTransaction((transaction) async {
        // Get fresh data
        final freshDoc = await transaction.get(documentReference);
        if (!freshDoc.exists) {
          throw Exception('User document no longer exists');
        }

        // Get current programs
        List<String> currentPrograms =
            List<String>.from(freshDoc.data()?['programs'] ?? []);

        // Validasi kombinasi program
        if (programId == 'GMM' && currentPrograms.contains('IFIS') ||
            programId == 'IFIS' && currentPrograms.contains('GMM')) {
          throw Exception(
              'Invalid program combination: GMM and IFIS cannot be taken together');
        }

        // Update arrays
        transaction.update(documentReference, {
          'programs': FieldValue.arrayUnion([programId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // 8. Verify update success
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
      // 1. Validasi file
      if (!imageFile.existsSync()) {
        debugPrint('Profile picture file not found');
        return const Result.failed('File not found');
      }

      // 2. Verify user di Authentication
      try {
        final authMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(user.email);
        if (authMethods.isEmpty) {
          debugPrint('User not found in Authentication: ${user.email}');
          return const Result.failed('User authentication issue detected');
        }
      } catch (authError) {
        debugPrint('Authentication verification failed: $authError');
        return Result.failed(
            'Authentication verification failed: ${authError.toString()}');
      }

      // 3. Validasi ukuran dan tipe file
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB limit
        return const Result.failed('File size exceeds 5MB limit');
      }

      final fileExtension = path.extension(imageFile.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png'].contains(fileExtension)) {
        return const Result.failed('Only JPG and PNG files are allowed');
      }

      // 4. Create unique filename
      String filename = 'profile_pictures/${user.uid}$fileExtension';
      Reference reference = _storage.ref().child(filename);

      // 5. Upload file dengan metadata
      final metadata = SettableMetadata(
          contentType: 'image/${fileExtension.substring(1)}',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          });
      await reference.putFile(imageFile, metadata);

      // 6. Get download URL
      String downloadUrl = await reference.getDownloadURL();
      debugPrint('Profile picture uploaded successfully: $downloadUrl');

      // 7. Update user dengan URL baru
      final updatedUser = user.copyWith(photoUrl: downloadUrl);
      final updateResult = await updateUser(user: updatedUser);

      if (!updateResult.isSuccess) {
        // Cleanup uploaded image jika update user gagal
        try {
          await reference.delete();
          debugPrint('Cleaned up uploaded image after failed update');
        } catch (e) {
          debugPrint('Failed to cleanup uploaded image: $e');
        }
        return Result.failed(updateResult.errorMessage!);
      }

      return updateResult;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading profile picture: ${e.message}');
      return Result.failed(e.message ?? 'Failed to upload profile picture');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Result.failed('Failed to upload profile picture: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      // 1. Validasi email kosong
      if (email.isEmpty) {
        return const Result.failed('Email tidak boleh kosong');
      }

      // 2. Validasi format email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return const Result.failed('Format email tidak valid');
      }

      // 3. Verifikasi email terdaftar di Authentication
      try {
        final signInMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isEmpty) {
          debugPrint('Email not found in Authentication: $email');
          return const Result.failed('Email tidak ditemukan');
        }
      } catch (e) {
        debugPrint('Error checking email existence: $e');
        return const Result.failed('Gagal memverifikasi email');
      }

      // 4. Kirim email reset password
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');

      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error on password reset: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return const Result.failed('Email tidak ditemukan');
        case 'invalid-email':
          return const Result.failed('Format email tidak valid');
        case 'user-disabled':
          return const Result.failed('Akun telah dinonaktifkan');
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
      // 1. Validasi program ID
      if (programId.isEmpty) {
        debugPrint('Empty program ID provided');
        return const Result.failed('Program ID tidak boleh kosong');
      }

      // 2. Query santri dengan program tertentu
      final querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: 'santri')
          .where('programs', arrayContains: programId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No santri found for program: $programId');
        return const Result.success(
            []); // Return empty list jika tidak ada santri
      }

      // 3. Process setiap santri
      List<User> santriList = [];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // 4. Verifikasi existence di Authentication
          final signInMethods =
              await _firebaseAuth.fetchSignInMethodsForEmail(data['email']);
          if (signInMethods.isEmpty) {
            debugPrint('Santri not found in Authentication: ${data['email']}');
            continue; // Skip santri yang tidak ada di Authentication
          }

          // 5. Konversi data dengan proper timestamp handling
          final convertedData = {
            ...data,
            'dateOfBirth':
                _convertTimestamp(data['dateOfBirth'])?.toIso8601String(),
            'createdAt':
                _convertTimestamp(data['createdAt'])?.toIso8601String(),
            'updatedAt':
                _convertTimestamp(data['updatedAt'])?.toIso8601String(),
          };

          // 6. Create dan validasi User entity
          final santri = User.fromJson(convertedData);
          if (!santri.isActive) {
            debugPrint('Skipping inactive santri: ${santri.email}');
            continue;
          }

          santriList.add(santri);
        } catch (e) {
          debugPrint('Error processing santri document ${doc.id}: $e');
          continue; // Skip invalid data
        }
      }

      debugPrint(
          'Retrieved ${santriList.length} santri for program: $programId');
      return Result.success(santriList);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting santri list: ${e.message}');
      return Result.failed('Failed to get santri list: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Result.failed('Failed to get santri list: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      // 1. Validasi UID
      if (uid.isEmpty) {
        debugPrint('Empty UID provided');
        return const Result.failed('User ID tidak boleh kosong');
      }

      // 2. Get user data untuk verifikasi
      DocumentReference<Map<String, dynamic>> userRef =
          _firebaseFirestore.doc('users/$uid');
      DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

      if (!userDoc.exists) {
        return const Result.failed('User not found');
      }

      // 3. Cek apakah user superAdmin
      final userRole = userDoc.data()!['role'] as String;
      if (userRole == 'superAdmin') {
        debugPrint('Attempted to delete superAdmin account');
        return const Result.failed('Cannot delete Super Admin user');
      }

      // 4. Hapus profile picture jika ada
      final photoUrl = userDoc.data()!['photoUrl'] as String?;
      if (photoUrl != null) {
        try {
          final photoRef = _storage.refFromURL(photoUrl);
          await photoRef.delete();
          debugPrint('Deleted user profile picture');
        } catch (e) {
          debugPrint('Failed to delete profile picture: $e');
          // Continue deletion even if photo deletion fails
        }
      }

      // 5. Verifikasi dan hapus dari Authentication
      try {
        final email = userDoc.data()!['email'] as String;
        final authMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(email);

        if (authMethods.isNotEmpty) {
          // Cari user yang sedang login di Authentication
          final currentAuthUser = _firebaseAuth.currentUser;
          if (currentAuthUser?.email == email) {
            // Delete auth user jika ditemukan
            await currentAuthUser?.delete();
            debugPrint('Deleted user from Authentication');
          }
        }
      } catch (e) {
        debugPrint('Error deleting from Authentication: $e');
        // Continue to delete from Firestore
      }

      // 6. Hapus user document
      await userRef.delete();
      debugPrint('Successfully deleted user: $uid');

      // 7. Verifikasi penghapusan
      final verifyDoc = await userRef.get();
      if (!verifyDoc.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Failed to verify user deletion');
      }
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
      // 1. Validasi input
      if (uid.isEmpty || programId.isEmpty) {
        debugPrint('Invalid parameters - UID: $uid, ProgramID: $programId');
        return const Result.failed('Parameter tidak valid');
      }

      // 2. Get user reference
      DocumentReference<Map<String, dynamic>> userRef =
          _firebaseFirestore.doc('users/$uid');

      // 3. Get dan validasi user data
      DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();
      if (!userDoc.exists) {
        debugPrint('User not found: $uid');
        return const Result.failed('User not found');
      }

      // 4. Validasi user aktif di Authentication
      try {
        final email = userDoc.data()!['email'] as String;
        final authMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(email);
        if (authMethods.isEmpty) {
          debugPrint('User not found in Authentication: $email');
          return const Result.failed('User authentication issue detected');
        }
      } catch (e) {
        debugPrint('Error verifying authentication: $e');
        return Result.failed(
            'Authentication verification failed: ${e.toString()}');
      }

      // 5. Validasi current programs
      List<String> programs =
          List<String>.from(userDoc.data()!['programs'] ?? []);
      if (!programs.contains(programId)) {
        debugPrint('User is not enrolled in program: $programId');
        return const Result.failed('User is not enrolled in this program');
      }

      // 6. Update programs dalam transaction
      await _firebaseFirestore.runTransaction((transaction) async {
        final freshDoc = await transaction.get(userRef);
        if (!freshDoc.exists) {
          throw Exception('User document no longer exists');
        }

        List<String> currentPrograms =
            List<String>.from(freshDoc.data()!['programs'] ?? []);
        currentPrograms.remove(programId);

        transaction.update(userRef, {
          'programs': currentPrograms,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // 7. Verifikasi update
      final verifyDoc = await userRef.get();
      final updatedPrograms =
          List<String>.from(verifyDoc.data()!['programs'] ?? []);
      if (updatedPrograms.contains(programId)) {
        return const Result.failed('Failed to remove program from user');
      }

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
