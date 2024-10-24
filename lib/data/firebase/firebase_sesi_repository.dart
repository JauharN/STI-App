import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/sesi.dart';

class FirebaseSesiRepository implements SesiRepository {
  final FirebaseFirestore _firestore;

  FirebaseSesiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Sesi>> createSesi(Sesi sesi) async {
    try {
      // Validasi waktu sesi
      if (sesi.waktuMulai.isAfter(sesi.waktuSelesai)) {
        return const Result.failed(
            'Waktu mulai tidak boleh lebih dari waktu selesai');
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('sesi').doc();

      final sesiData = {
        ...sesi.toJson(),
        'id': documentReference.id,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await documentReference.set(sesiData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(Sesi.fromJson(result.data()!));
      } else {
        return const Result.failed('Failed to create sesi');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create sesi');
    }
  }

  @override
  Future<Result<List<Sesi>>> getSesiByProgramId(String programId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('sesi')
          .where('programId', isEqualTo: programId)
          .orderBy('waktuMulai')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Sesi> sesiList =
            querySnapshot.docs.map((doc) => Sesi.fromJson(doc.data())).toList();
        return Result.success(sesiList);
      } else {
        return const Result.failed('No sesi found for this program');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get sesi');
    }
  }

  @override
  Future<Result<List<Sesi>>> getUpcomingSesi(String programId) async {
    try {
      // Ambil sesi yang waktu mulainya lebih dari waktu sekarang
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('sesi')
          .where('programId', isEqualTo: programId)
          .where('waktuMulai', isGreaterThan: DateTime.now())
          .orderBy('waktuMulai')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Sesi> sesiList =
            querySnapshot.docs.map((doc) => Sesi.fromJson(doc.data())).toList();
        return Result.success(sesiList);
      } else {
        return const Result.failed('No upcoming sesi found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get upcoming sesi');
    }
  }

  @override
  Future<Result<Sesi>> updateSesi(Sesi sesi) async {
    try {
      if (sesi.waktuMulai.isAfter(sesi.waktuSelesai)) {
        return const Result.failed(
            'Waktu mulai tidak boleh lebih dari waktu selesai');
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('sesi/${sesi.id}');

      final updateData = {
        ...sesi.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentReference.update(updateData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(Sesi.fromJson(result.data()!));
      } else {
        return const Result.failed('Sesi not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update sesi');
    }
  }

  @override
  Future<Result<void>> deleteSesi(String sesiId) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('sesi/$sesiId');

      await documentReference.delete();

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (!result.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Failed to delete sesi');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete sesi');
    }
  }
}
