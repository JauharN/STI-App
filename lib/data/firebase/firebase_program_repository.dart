import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/program.dart';
import 'package:sti_app/domain/entities/result.dart';

class FirebaseProgramRepository implements ProgramRepository {
  final FirebaseFirestore _firestore;

  FirebaseProgramRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Program>> createProgram(Program program) async {
    try {
      // Validasi tipe program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(program.nama)) {
        return const Result.failed('Invalid program name');
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('programs').doc();

      final programData = {
        ...program.toJson(),
        'id': documentReference.id,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await documentReference.set(programData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(Program.fromJson(result.data()!));
      } else {
        return const Result.failed('Failed to create program');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create program');
    }
  }

  @override
  Future<Result<void>> deleteProgram(String programId) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('programs/$programId');

      await documentReference.delete();

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (!result.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Failed to delete program');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete program');
    }
  }

  @override
  Future<Result<List<Program>>> getAllPrograms() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('programs').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Program> programs = querySnapshot.docs
            .map((doc) => Program.fromJson(doc.data()))
            .toList();
        return Result.success(programs);
      } else {
        return const Result.failed('No programs found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get programs');
    }
  }

  @override
  Future<Result<Program>> getProgramById(String programId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('programs').doc(programId).get();

      if (doc.exists) {
        return Result.success(Program.fromJson(doc.data()!));
      } else {
        return const Result.failed('Program not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get program');
    }
  }

  @override
  Future<Result<List<Program>>> getProgramsByUserId(String userId) async {
    try {
      // Pertama ambil data user untuk mendapatkan program IDs yang diikuti
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return const Result.failed('User not found');
      }

      // Ambil array program IDs dari dokumen user
      List<String> programIds =
          List<String>.from(userDoc.data()?['programs'] ?? []);

      if (programIds.isEmpty) {
        return const Result.failed('User has no enrolled programs');
      }

      // Ambil data program berdasarkan program IDs
      List<Program> programs = [];
      for (String programId in programIds) {
        DocumentSnapshot<Map<String, dynamic>> programDoc =
            await _firestore.collection('programs').doc(programId).get();

        if (programDoc.exists) {
          programs.add(Program.fromJson(programDoc.data()!));
        }
      }

      if (programs.isNotEmpty) {
        return Result.success(programs);
      } else {
        return const Result.failed('No programs found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get user programs');
    }
  }

  @override
  Future<Result<Program>> updateProgram(Program program) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('programs/${program.id}');

      final updateData = {
        ...program.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentReference.update(updateData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(Program.fromJson(result.data()!));
      } else {
        return const Result.failed('Program not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update program');
    }
  }
}
