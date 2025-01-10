import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/presensi/detail_presensi.dart';
import '../../domain/entities/presensi/presensi_pertemuan.dart';
import '../../domain/entities/presensi/presensi_statistics_data.dart';
import '../../domain/entities/presensi/presensi_status.dart';
import '../../domain/entities/presensi/presensi_summary.dart';
import '../../domain/entities/presensi/santri_presensi.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/presensi/santri_statistics.dart';
import '../repositories/presensi_repository.dart';

class FirebasePresensiRepository implements PresensiRepository {
  final FirebaseFirestore _firestore;

  FirebasePresensiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // HELPER METHODS

  Future<bool> _isPertemuanExists(String programId, int pertemuanKe) async {
    final snapshot = await _firestore
        .collection('presensi_pertemuan')
        .where('programId', isEqualTo: programId)
        .where('pertemuanKe', isEqualTo: pertemuanKe)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // IMPLEMENTATION OF REPOSITORY METHODS

  @override
  Future<Result<PresensiPertemuan>> createPresensiPertemuan(
      PresensiPertemuan presensiPertemuan) async {
    try {
      // Validasi program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(presensiPertemuan.programId)) {
        return const Result.failed('Program ID tidak valid');
      }

      // Cek duplikasi pertemuan
      if (await _isPertemuanExists(
          presensiPertemuan.programId, presensiPertemuan.pertemuanKe)) {
        return Result.failed(
            'Pertemuan ke-${presensiPertemuan.pertemuanKe} sudah ada');
      }

      // Validasi tanggal
      if (presensiPertemuan.tanggal.isAfter(DateTime.now())) {
        return const Result.failed('Tanggal tidak boleh di masa depan');
      }

      // Validasi daftar hadir
      if (presensiPertemuan.daftarHadir.isEmpty) {
        return const Result.failed('Daftar hadir tidak boleh kosong');
      }

      // Validasi summary
      if (presensiPertemuan.summary.totalSantri !=
          presensiPertemuan.daftarHadir.length) {
        return const Result.failed(
            'Data summary tidak sesuai dengan daftar hadir');
      }

      // Proses create
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('presensi_pertemuan').doc();

      final presensiData = {
        ...presensiPertemuan
            .copyWith(
              id: documentReference.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
            .toJson(),
      };

      // Gunakan writeBatch untuk atomic operation yang lebih efisien
      final batch = _firestore.batch();

      // Set data presensi
      batch.set(documentReference, presensiData);

      // Commit batch
      await batch.commit();

      // Verifikasi hasil
      final result = await documentReference.get();
      if (result.exists) {
        return Result.success(PresensiPertemuan.fromJson(result.data()!));
      } else {
        return const Result.failed('Gagal membuat presensi pertemuan');
      }
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
      if (pertemuanKe <= 0) {
        return const Result.failed('Nomor pertemuan harus positif');
      }

      final querySnapshot = await _firestore
          .collection('presensi_pertemuan')
          .where('programId', isEqualTo: programId)
          .where('pertemuanKe', isEqualTo: pertemuanKe)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Result.failed('Pertemuan ke-$pertemuanKe tidak ditemukan');
      }

      return Result.success(
          PresensiPertemuan.fromJson(querySnapshot.docs.first.data()));
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<PresensiPertemuan>>> getAllPresensiPertemuan(
      String programId) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi_pertemuan')
          .where('programId', isEqualTo: programId)
          .orderBy('pertemuanKe')
          .get();

      final presensiList = querySnapshot.docs
          .map((doc) => PresensiPertemuan.fromJson(doc.data()))
          .toList();

      return Result.success(presensiList);
    } catch (e) {
      return Result.failed('Error getting all presensi: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiPertemuan>> updatePresensiPertemuan(
      PresensiPertemuan presensiPertemuan) async {
    try {
      // Basic validations
      if (!presensiPertemuan.isValid) {
        return const Result.failed('Data presensi tidak valid');
      }

      final docRef =
          _firestore.collection('presensi_pertemuan').doc(presensiPertemuan.id);

      final updateData = {
        ...presensiPertemuan
            .copyWith(
              updatedAt: DateTime.now(),
            )
            .toJson(),
      };

      // Gunakan batch untuk update summary juga
      final batch = _firestore.batch();
      batch.update(docRef, updateData);

      await batch.commit();

      final result = await docRef.get();
      if (result.exists) {
        return Result.success(PresensiPertemuan.fromJson(result.data()!));
      } else {
        return const Result.failed('Presensi pertemuan tidak ditemukan');
      }
    } catch (e) {
      return Result.failed('Error updating presensi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePresensiPertemuan(String id) async {
    try {
      await _firestore.collection('presensi_pertemuan').doc(id).delete();
      return const Result.success(null);
    } catch (e) {
      return Result.failed('Error deleting presensi: ${e.toString()}');
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

      // Get pengajar details
      final pengajarId = programDoc.data()?['pengajarId'];
      final pengajarDoc =
          await _firestore.collection('users').doc(pengajarId).get();

      // Get presensi untuk bulan dan tahun yang diminta
      final startDate = DateTime(int.parse(tahun), int.parse(bulan), 1);
      final endDate = DateTime(int.parse(tahun), int.parse(bulan) + 1, 0);

      final presensiQuery = await _firestore
          .collection('presensi_pertemuan')
          .where('programId', isEqualTo: programId)
          .where('tanggal', isGreaterThanOrEqualTo: startDate)
          .where('tanggal', isLessThanOrEqualTo: endDate)
          .orderBy('tanggal')
          .get();

      // Transform ke PresensiDetailItem
      final List<PresensiDetailItem> pertemuan = [];
      for (var doc in presensiQuery.docs) {
        final data = doc.data();
        final daftarHadir = (data['daftarHadir'] as List)
            .map((d) => SantriPresensi.fromJson(d))
            .where((s) => s.santriId == userId)
            .toList();

        if (daftarHadir.isNotEmpty) {
          pertemuan.add(PresensiDetailItem(
            pertemuanKe: data['pertemuanKe'],
            status: daftarHadir.first.status,
            tanggal: (data['tanggal'] as Timestamp).toDate(),
            keterangan: daftarHadir.first.keterangan,
          ));
        }
      }

      return Result.success(DetailPresensi(
        programName: programDoc.data()?['nama'] ?? '',
        kelas: programDoc.data()?['kelas'] ?? '',
        pengajarName: pengajarDoc.data()?['name'] ?? '',
        pertemuan: pertemuan,
        programId: programId,
      ));
    } catch (e) {
      return Result.failed('Error getting detail presensi: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiSummary>> getPresensiSummary({
    required String userId,
    required String programId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('presensi_pertemuan')
          .where('programId', isEqualTo: programId)
          .get();

      int hadir = 0, sakit = 0, izin = 0, alpha = 0, total = 0;

      // Hitung summary dari semua presensi pertemuan
      for (var doc in querySnapshot.docs) {
        final daftarHadir = (doc.data()['daftarHadir'] as List)
            .map((d) => SantriPresensi.fromJson(d))
            .where((s) => s.santriId == userId)
            .toList();

        if (daftarHadir.isNotEmpty) {
          total++;
          switch (daftarHadir.first.status) {
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
      }

      return Result.success(PresensiSummary(
        totalSantri: total,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Result.failed('Error getting presensi summary: ${e.toString()}');
    }
  }

  @override
  Future<Result<PresensiPertemuan>> getPresensiById(String id) async {
    try {
      final doc =
          await _firestore.collection('presensi_pertemuan').doc(id).get();

      if (!doc.exists) {
        return const Failed('Presensi tidak ditemukan');
      }

      return Success(PresensiPertemuan.fromJson(doc.data()!));
    } catch (e) {
      return Failed(e.toString());
    }
  }

  @override
  Future<Result<PresensiStatisticsData>> getPresensiStatistics({
    required String programId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Buat query dasar
      Query<Map<String, dynamic>> query = _firestore
          .collection('presensi_pertemuan')
          .where('programId', isEqualTo: programId);

      // Tambahkan filter tanggal jika ada
      if (startDate != null) {
        query = query.where('tanggal', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('tanggal', isLessThanOrEqualTo: endDate);
      }

      // Ambil data presensi
      final presensiDocs = await query.get();
      final presensiList = presensiDocs.docs
          .map((doc) => PresensiPertemuan.fromJson(doc.data()))
          .toList();

      if (presensiList.isEmpty) {
        return Result.success(PresensiStatisticsData(
          programId: programId,
          totalPertemuan: 0,
          totalSantri: 0,
          trendKehadiran: {},
          totalByStatus: {},
          santriStats: [],
          lastUpdated: DateTime.now(),
        ));
      }

      // Calculate statistics
      final totalPertemuan = presensiList.length;
      final totalSantri = presensiList.first.summary.totalSantri;

      // Calculate trend kehadiran
      final trendKehadiran = _calculateTrendKehadiran(presensiList);

      // Calculate total by status
      final totalByStatus = _calculateTotalByStatus(presensiList);

      // Calculate santri statistics
      final santriStats = await _calculateSantriStatistics(presensiList);

      final statisticsData = PresensiStatisticsData(
        programId: programId,
        totalPertemuan: totalPertemuan,
        totalSantri: totalSantri,
        trendKehadiran: trendKehadiran,
        totalByStatus: totalByStatus,
        santriStats: santriStats,
        lastUpdated: DateTime.now(),
      );

      return Result.success(statisticsData);
    } catch (e) {
      return Result.failed('Gagal mengambil statistik: ${e.toString()}');
    }
  }

// Helper methods untuk kalkulasi
  Map<String, double> _calculateTrendKehadiran(
      List<PresensiPertemuan> presensiList) {
    final Map<String, double> trend = {};
    for (var presensi in presensiList) {
      final date = DateFormat('yyyy-MM-dd').format(presensi.tanggal);
      trend[date] =
          (presensi.summary.hadir / presensi.summary.totalSantri) * 100;
    }
    return trend;
  }

  Map<PresensiStatus, int> _calculateTotalByStatus(
      List<PresensiPertemuan> presensiList) {
    final Map<PresensiStatus, int> totalByStatus = {};
    for (var presensi in presensiList) {
      for (var santri in presensi.daftarHadir) {
        totalByStatus.update(
          santri.status,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    return totalByStatus;
  }

  Future<List<SantriStatistics>> _calculateSantriStatistics(
      List<PresensiPertemuan> presensiList) async {
    final Map<String, Map<String, dynamic>> santriStatsMap = {};

    // Initialize stats for each santri
    for (var presensi in presensiList) {
      for (var santri in presensi.daftarHadir) {
        if (!santriStatsMap.containsKey(santri.santriId)) {
          santriStatsMap[santri.santriId] = {
            'santriName': santri.santriName,
            'totalKehadiran': 0,
            'statusCount': <PresensiStatus, int>{},
          };
        }

        // Update status count
        santriStatsMap[santri.santriId]!['statusCount'].update(
          santri.status,
          (value) => value + 1,
          ifAbsent: () => 1,
        );

        // Update total kehadiran
        if (santri.status == PresensiStatus.hadir) {
          santriStatsMap[santri.santriId]!['totalKehadiran'] =
              santriStatsMap[santri.santriId]!['totalKehadiran']! + 1;
        }
      }
    }

    // Convert to list of SantriStatistics
    return santriStatsMap.entries.map((entry) {
      final stats = entry.value;
      return SantriStatistics(
        santriId: entry.key,
        santriName: stats['santriName'],
        totalKehadiran: stats['totalKehadiran'],
        totalPertemuan: presensiList.length,
        statusCount: stats['statusCount'],
        persentaseKehadiran:
            (stats['totalKehadiran'] / presensiList.length) * 100,
      );
    }).toList();
  }
}
