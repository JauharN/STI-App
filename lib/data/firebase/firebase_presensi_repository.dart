import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/presensi/detail_presensi.dart';
import '../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../domain/entities/presensi/presensi_statistics_data.dart';
import '../../domain/entities/presensi/presensi_status.dart';
import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/presensi/santri_presensi.dart';
import '../../domain/entities/result.dart';

import '../../presentation/utils/presensi_statistics_helper.dart';
import '../repositories/presensi_repository.dart';

class FirebasePresensiRepository implements PresensiRepository {
  final FirebaseFirestore _firestore;

  FirebasePresensiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<PresensiPertemuan>> createPresensiPertemuan(
      PresensiPertemuan presensiPertemuan) async {
    try {
      final docRef = _firestore.collection('presensi').doc();

      // Transform and validate data
      Map<String, dynamic> data = {
        ...presensiPertemuan.toJson(),
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      // Save to Firebase
      await docRef.set(data);

      // Get saved data
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        return const Result.failed('Gagal menyimpan data presensi');
      }

      final savedData = docSnap.data()!;
      // Convert timestamps
      final createdAt = (savedData['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (savedData['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (savedData['tanggal'] as Timestamp).toDate();

      return Result.success(PresensiPertemuan.fromJson({
        ...savedData,
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
  Future<Result<PresensiPertemuan>> getPresensiPertemuan({
    required String programId,
    required int pertemuanKe,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .where('pertemuanKe', isEqualTo: pertemuanKe)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Result.failed(
            'Data presensi tidak ditemukan untuk pertemuan ke-$pertemuanKe');
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      // Convert timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (data['tanggal'] as Timestamp).toDate();

      return Result.success(PresensiPertemuan.fromJson({
        ...data,
        'id': doc.id,
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
  Future<Result<List<PresensiPertemuan>>> getAllPresensiPertemuan(
      String programId) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .orderBy('pertemuanKe', descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.failed('Belum ada data presensi untuk program ini');
      }

      List<PresensiPertemuan> presensiList = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
        final tanggal = (data['tanggal'] as Timestamp).toDate();

        presensiList.add(PresensiPertemuan.fromJson({
          ...data,
          'id': doc.id,
          'tanggal': tanggal.toIso8601String(),
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        }));
      }

      return Result.success(presensiList);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiPertemuan>> updatePresensiPertemuan(
      PresensiPertemuan presensiPertemuan) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection('presensi').doc(presensiPertemuan.id);

      // Verify existence
      final doc = await docRef.get();
      if (!doc.exists) {
        return const Result.failed('Presensi tidak ditemukan');
      }

      Map<String, dynamic> updateData = {
        ...presensiPertemuan.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      updateData.remove('id');
      updateData.remove('createdAt');

      await docRef.update(updateData);

      // Get updated data
      final updatedDoc = await docRef.get();
      final data = updatedDoc.data()!;

      // Convert timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (data['tanggal'] as Timestamp).toDate();

      return Result.success(PresensiPertemuan.fromJson({
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
  Future<Result<void>> deletePresensiPertemuan(String id) async {
    try {
      final docRef = _firestore.collection('presensi').doc(id);

      // Verify existence
      final doc = await docRef.get();
      if (!doc.exists) {
        return const Result.failed('Presensi tidak ditemukan');
      }

      await docRef.delete();

      // Verify deletion
      final verifyDoc = await docRef.get();
      if (!verifyDoc.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Gagal menghapus presensi');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<DetailPresensi>> getDetailPresensi({
    required String userId,
    required String programId,
    required String bulan,
    required String tahun,
  }) async {
    try {
      // Get program details
      final programDoc =
          await _firestore.collection('program').doc(programId).get();
      if (!programDoc.exists) {
        return const Result.failed('Program tidak ditemukan');
      }

      final programData = programDoc.data()!;

      // Get presensi for user in this program
      final presensiQuery = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .where('daftarHadir', arrayContains: {'santriId': userId}).get();

      if (presensiQuery.docs.isEmpty) {
        return const Result.failed('Data presensi tidak ditemukan');
      }

      List<PresensiDetailItem> pertemuan = [];
      for (var doc in presensiQuery.docs) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();

        // Filter by bulan and tahun
        if (tanggal.month.toString() != bulan ||
            tanggal.year.toString() != tahun) {
          continue;
        }

        // Get santri presensi status
        List<Map<String, dynamic>> daftarHadir =
            List<Map<String, dynamic>>.from(data['daftarHadir'] ?? []);

        var santriPresensi = daftarHadir.firstWhere(
          (p) => p['santriId'] == userId,
          orElse: () => {'status': 'alpha'},
        );

        pertemuan.add(PresensiDetailItem(
          pertemuanKe: data['pertemuanKe'],
          status: PresensiStatus.fromJson(santriPresensi['status']),
          tanggal: tanggal,
          materi: data['materi'],
          keterangan: santriPresensi['keterangan'],
        ));
      }

      if (pertemuan.isEmpty) {
        return const Result.failed(
            'Tidak ada presensi pada periode yang diminta');
      }

      return Result.success(DetailPresensi(
        programId: programId,
        programName: programData['nama'],
        kelas: programData['kelas'] ?? '',
        pengajarName: programData['pengajarName'] ?? 'Belum ditentukan',
        pertemuan: pertemuan,
      ));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiSummary>> getPresensiSummary({
    required String userId,
    required String programId,
  }) async {
    try {
      final presensiQuery = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .get();

      if (presensiQuery.docs.isEmpty) {
        return const Result.failed('Data presensi tidak ditemukan');
      }

      int hadir = 0, sakit = 0, izin = 0, alpha = 0;

      for (var doc in presensiQuery.docs) {
        final data = doc.data();
        List<Map<String, dynamic>> daftarHadir =
            List<Map<String, dynamic>>.from(data['daftarHadir'] ?? []);

        // Find santri data and transform to entity
        var santriData = daftarHadir.firstWhere(
          (p) => p['santriId'] == userId,
          orElse: () => {
            'santriId': userId,
            'santriName': '',
            'status': 'alpha',
            'keterangan': 'Tidak hadir'
          },
        );

        final santriPresensi = SantriPresensi.fromJson(santriData);

        switch (santriPresensi.status) {
          case PresensiStatus.hadir:
            hadir++;
            break;
          case PresensiStatus.sakit:
            sakit++;
            break;
          case PresensiStatus.izin:
            izin++;
            break;
          case PresensiStatus.alpha:
            alpha++;
            break;
        }
      }

      final totalSantri = presensiQuery.docs.length;
      if (totalSantri == 0) {
        return const Result.failed('Belum ada data presensi');
      }

      return Result.success(PresensiSummary(
        totalSantri: totalSantri,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiPertemuan>> getPresensiById(String id) async {
    try {
      final docSnapshot = await _firestore.collection('presensi').doc(id).get();

      if (!docSnapshot.exists) {
        return Result.failed('Presensi dengan ID: $id tidak ditemukan');
      }

      final data = docSnapshot.data()!;
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (data['tanggal'] as Timestamp).toDate();

      return Result.success(PresensiPertemuan.fromJson({
        ...data,
        'id': docSnapshot.id,
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
  Future<Result<PresensiStatisticsData>> getPresensiStatistics({
    required String programId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Get data dari Firebase
      final presensiDocs = await _getPresensiDocuments(
        programId: programId,
        startDate: startDate,
        endDate: endDate,
      );

      if (presensiDocs.isEmpty) {
        return const Result.failed('Tidak ada data presensi untuk periode ini');
      }

      // 2. Transform ke List<PresensiPertemuan>
      final presensiList = await _transformToPresensiList(presensiDocs);

      // 3. Gunakan helper untuk kalkulasi
      final trendKehadiran =
          PresensiStatisticsHelper.calculateTrendKehadiran(presensiList);
      final totalByStatus =
          PresensiStatisticsHelper.calculateTotalByStatus(presensiList);
      final santriStats =
          await PresensiStatisticsHelper.calculateSantriStatistics(
              presensiList);

      // 4. Return hasil dalam bentuk PresensiStatisticsData
      return Result.success(PresensiStatisticsData(
        programId: programId,
        totalPertemuan: presensiList.length,
        totalSantri: santriStats.length,
        trendKehadiran: trendKehadiran,
        totalByStatus: totalByStatus,
        santriStats: santriStats,
        lastUpdated: DateTime.now(),
      ));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

// Helper method untuk get documents dari Firebase
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _getPresensiDocuments({
    required String programId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('presensi')
        .where('programId', isEqualTo: programId);

    if (startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('tanggal', isLessThanOrEqualTo: endDate);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    return snapshot.docs;
  }

// Helper method untuk transform Firebase docs ke PresensiPertemuan
  Future<List<PresensiPertemuan>> _transformToPresensiList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    List<PresensiPertemuan> presensiList = [];

    for (var doc in docs) {
      final data = doc.data();
      // Convert timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final tanggal = (data['tanggal'] as Timestamp).toDate();

      try {
        final presensi = PresensiPertemuan.fromJson({
          ...data,
          'id': doc.id,
          'tanggal': tanggal.toIso8601String(),
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        });
        presensiList.add(presensi);
      } catch (e) {
        print('Error transforming document ${doc.id}: $e');
        continue;
      }
    }

    return presensiList;
  }

  @override
  Future<Result<List<PresensiPertemuan>>> getRecentPresensiPertemuan({
    required String programId,
    int? limit,
  }) async {
    try {
      var query = _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId);

      // Add time filter for last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      query = query.where('tanggal', isGreaterThanOrEqualTo: thirtyDaysAgo);

      // Add sorting and limit
      final querySnapshot = await query
          .orderBy('tanggal', descending: true)
          .orderBy('pertemuanKe', descending: true)
          .limit(limit ?? 5)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success([]);
      }

      List<PresensiPertemuan> presensiList = [];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          final tanggal = (data['tanggal'] as Timestamp).toDate();

          presensiList.add(PresensiPertemuan.fromJson({
            ...data,
            'id': doc.id,
            'tanggal': tanggal.toIso8601String(),
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          }));
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          continue;
        }
      }

      return Success(presensiList);
    } catch (e) {
      return Failed('Failed to get recent presensi: ${e.toString()}');
    }
  }
}
