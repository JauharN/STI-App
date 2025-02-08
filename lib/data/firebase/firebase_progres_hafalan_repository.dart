import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/progres_hafalan.dart';
import '../repositories/progres_hafalan_repository.dart';

class FirebaseProgresHafalanRepository implements ProgresHafalanRepository {
  final FirebaseFirestore _firestore;

  FirebaseProgresHafalanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<ProgresHafalan>> createProgresHafalan(
      ProgresHafalan progresHafalan) async {
    try {
      // Validasi program ID
      if (!['TAHFIDZ', 'GMM'].contains(progresHafalan.programId)) {
        return const Result.failed('Program ID tidak valid');
      }

      // Validasi data berdasarkan jenis program
      if (progresHafalan.programId == 'TAHFIDZ') {
        // Validasi field khusus Tahfidz
        if (progresHafalan.juz == null ||
            progresHafalan.halaman == null ||
            progresHafalan.ayat == null ||
            progresHafalan.surah?.isEmpty == true ||
            progresHafalan.statusPenilaian?.isEmpty == true) {
          return const Result.failed('Data Tahfidz tidak lengkap');
        }

        // Validasi status penilaian
        if (!['Lancar', 'Belum', 'Perlu Perbaikan']
            .contains(progresHafalan.statusPenilaian)) {
          return const Result.failed('Status penilaian tidak valid');
        }
      } else {
        // Validasi field khusus GMM
        if (progresHafalan.iqroLevel == null ||
            progresHafalan.iqroHalaman == null ||
            progresHafalan.statusIqro?.isEmpty == true ||
            progresHafalan.mutabaahTarget?.isEmpty == true ||
            progresHafalan.statusMutabaah?.isEmpty == true) {
          return const Result.failed('Data GMM tidak lengkap');
        }

        // Validasi status GMM
        if (!['1', '2', '3', '4', '5', '6']
            .contains(progresHafalan.iqroLevel)) {
          return const Result.failed('Level Iqro tidak valid');
        }
        if (!['Lancar', 'Belum'].contains(progresHafalan.statusIqro)) {
          return const Result.failed('Status Iqro tidak valid');
        }
        if (!['Tercapai', 'Belum'].contains(progresHafalan.statusMutabaah)) {
          return const Result.failed('Status Mutabaah tidak valid');
        }
      }

      // Create document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('progres_hafalan').doc();

      // Transform dan validate data
      Map<String, dynamic> data = {
        ...progresHafalan.toJson(),
        'id': documentReference.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      // Save to Firebase
      await documentReference.set(data);

      // Get saved data
      final docSnap = await documentReference.get();
      if (!docSnap.exists) {
        return const Result.failed('Gagal menyimpan progres hafalan');
      }

      final savedData = docSnap.data()!;

      // Convert timestamps
      final createdAt = (savedData['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (savedData['updatedAt'] as Timestamp?)?.toDate();

      return Result.success(ProgresHafalan.fromJson({
        ...savedData,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      }));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByUserId(
      String userId) async {
    try {
      // Validasi user ID
      if (userId.isEmpty) {
        return const Result.failed('User ID tidak boleh kosong');
      }

      // Query dengan ordering
      final querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success(
            []); // Return empty list jika tidak ada data
      }

      List<ProgresHafalan> progresList = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Convert timestamps
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          final tanggal = (data['tanggal'] as Timestamp).toDate();

          progresList.add(ProgresHafalan.fromJson({
            ...data,
            'id': doc.id,
            'tanggal': tanggal.toIso8601String(),
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          }));
        } catch (e) {
          debugPrint('Error parsing document ${doc.id}: $e');
          continue; // Skip invalid documents
        }
      }

      // Sort by tanggal (latest first)
      progresList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return Result.success(progresList);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<ProgresHafalan>> updateProgresHafalan(
      ProgresHafalan progresHafalan) async {
    try {
      // Verify document exists
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('progres_hafalan/${progresHafalan.id}');

      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await documentReference.get();
      if (!docSnapshot.exists) {
        return const Result.failed('Data progres hafalan tidak ditemukan');
      }

      // Validasi program ID
      if (!['TAHFIDZ', 'GMM'].contains(progresHafalan.programId)) {
        return const Result.failed('Program ID tidak valid');
      }

      // Validasi data berdasarkan jenis program
      if (progresHafalan.programId == 'TAHFIDZ') {
        if (progresHafalan.juz == null ||
            progresHafalan.halaman == null ||
            progresHafalan.ayat == null ||
            progresHafalan.surah?.isEmpty == true ||
            progresHafalan.statusPenilaian?.isEmpty == true) {
          return const Result.failed('Data Tahfidz tidak lengkap');
        }

        // Validasi status penilaian
        if (!['Lancar', 'Belum', 'Perlu Perbaikan']
            .contains(progresHafalan.statusPenilaian)) {
          return const Result.failed('Status penilaian tidak valid');
        }
      } else {
        if (progresHafalan.iqroLevel == null ||
            progresHafalan.iqroHalaman == null ||
            progresHafalan.statusIqro?.isEmpty == true ||
            progresHafalan.mutabaahTarget?.isEmpty == true ||
            progresHafalan.statusMutabaah?.isEmpty == true) {
          return const Result.failed('Data GMM tidak lengkap');
        }

        // Validasi status GMM
        if (!['1', '2', '3', '4', '5', '6']
            .contains(progresHafalan.iqroLevel)) {
          return const Result.failed('Level Iqro tidak valid');
        }
        if (!['Lancar', 'Belum'].contains(progresHafalan.statusIqro)) {
          return const Result.failed('Status Iqro tidak valid');
        }
        if (!['Tercapai', 'Belum'].contains(progresHafalan.statusMutabaah)) {
          return const Result.failed('Status Mutabaah tidak valid');
        }
      }

      // Prepare update data
      Map<String, dynamic> updateData = {
        ...progresHafalan.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove fields yang tidak perlu diupdate
      updateData.remove('id');
      updateData.remove('createdAt');
      updateData.remove('createdBy');

      // Remove null values
      updateData.removeWhere((key, value) => value == null);

      // Update document
      await documentReference.update(updateData);

      // Get updated data
      final updatedDoc = await documentReference.get();
      final data = updatedDoc.data()!;

      // Convert timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (data['tanggal'] as Timestamp).toDate();

      return Result.success(ProgresHafalan.fromJson({
        ...data,
        'id': updatedDoc.id,
        'tanggal': tanggal.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      }));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteProgresHafalan(String progresHafalanId) async {
    try {
      // Validasi ID
      if (progresHafalanId.isEmpty) {
        return const Result.failed('ID progres hafalan tidak boleh kosong');
      }

      // Get document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('progres_hafalan/$progresHafalanId');

      // Verify existence
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await documentReference.get();
      if (!docSnapshot.exists) {
        return const Result.failed('Data progres hafalan tidak ditemukan');
      }

      // Delete document
      await documentReference.delete();

      // Verify deletion
      DocumentSnapshot<Map<String, dynamic>> verifyDoc =
          await documentReference.get();
      if (!verifyDoc.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Gagal menghapus data progres hafalan');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<ProgresHafalan>> getLatestProgresHafalan(String userId) async {
    try {
      // Validasi user ID
      if (userId.isEmpty) {
        return const Result.failed('User ID tidak boleh kosong');
      }

      // Query untuk progres hafalan terbaru dari user
      final querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .limit(1)
          .get();

      // Return null jika tidak ada data
      if (querySnapshot.docs.isEmpty) {
        return const Result.failed('Belum ada data progres hafalan');
      }

      try {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        // Convert timestamps
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
        final tanggal = (data['tanggal'] as Timestamp).toDate();

        return Result.success(ProgresHafalan.fromJson({
          ...data,
          'id': doc.id,
          'tanggal': tanggal.toIso8601String(),
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        }));
      } catch (e) {
        debugPrint('Error parsing progres hafalan: $e');
        return const Result.failed('Gagal memproses data progres hafalan');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validasi user ID
      if (userId.isEmpty) {
        return const Result.failed('User ID tidak boleh kosong');
      }

      // Validasi date range
      if (startDate.isAfter(endDate)) {
        return const Result.failed(
            'Tanggal awal tidak boleh setelah tanggal akhir');
      }

      // Query dengan filter tanggal
      final querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('userId', isEqualTo: userId)
          .where('tanggal', isGreaterThanOrEqualTo: startDate)
          .where('tanggal',
              isLessThanOrEqualTo: endDate.add(const Duration(days: 1)))
          .orderBy('tanggal', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success(
            []); // Return empty list jika tidak ada data
      }

      List<ProgresHafalan> progresList = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Convert timestamps
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          final tanggal = (data['tanggal'] as Timestamp).toDate();

          progresList.add(ProgresHafalan.fromJson({
            ...data,
            'id': doc.id,
            'tanggal': tanggal.toIso8601String(),
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          }));
        } catch (e) {
          debugPrint('Error parsing document ${doc.id}: $e');
          continue; // Skip invalid documents
        }
      }

      // Sort by tanggal
      progresList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return Result.success(progresList);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByProgramId(
      String programId) async {
    try {
      // Validasi program ID
      if (!['TAHFIDZ', 'GMM'].contains(programId)) {
        return const Result.failed('Program ID tidak valid');
      }

      // Query untuk get data berdasarkan program
      final querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('programId', isEqualTo: programId)
          .orderBy('tanggal', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.success(
            []); // Return empty list jika tidak ada data
      }

      List<ProgresHafalan> progresList = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Convert timestamps
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          final tanggal = (data['tanggal'] as Timestamp).toDate();

          // Validasi data berdasarkan jenis program
          if (programId == 'TAHFIDZ') {
            if (data['juz'] == null ||
                data['halaman'] == null ||
                data['ayat'] == null ||
                data['surah']?.toString().isEmpty == true ||
                data['statusPenilaian']?.toString().isEmpty == true) {
              debugPrint('Invalid TAHFIDZ data for doc ${doc.id}');
              continue;
            }
          } else {
            // GMM
            if (data['iqroLevel'] == null ||
                data['iqroHalaman'] == null ||
                data['statusIqro']?.toString().isEmpty == true ||
                data['mutabaahTarget']?.toString().isEmpty == true ||
                data['statusMutabaah']?.toString().isEmpty == true) {
              debugPrint('Invalid GMM data for doc ${doc.id}');
              continue;
            }
          }

          progresList.add(ProgresHafalan.fromJson({
            ...data,
            'id': doc.id,
            'tanggal': tanggal.toIso8601String(),
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          }));
        } catch (e) {
          debugPrint('Error parsing document ${doc.id}: $e');
          continue; // Skip invalid documents
        }
      }

      // Sort by tanggal (terbaru di atas)
      progresList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return Result.success(progresList);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }
}
