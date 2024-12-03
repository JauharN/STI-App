import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sti_app/domain/entities/presensi/detail_presensi.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/presensi/santri_presensi.dart';
import 'package:sti_app/domain/entities/result.dart';
import '../repositories/presensi_repository.dart';

class FirebasePresensiRepository implements PresensiRepository {
  final FirebaseFirestore _firestore;

  FirebasePresensiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // HELPER METHODS

  /// Memvalidasi data presensi sebelum operasi create/update
  Result<void> _validatePresensiData(PresensiPertemuan presensi) {
    // Validasi program ID
    if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(presensi.programId)) {
      return const Result.failed('Invalid program ID');
    }

    // Validasi daftar hadir tidak kosong
    if (presensi.daftarHadir.isEmpty) {
      return const Result.failed('Daftar hadir tidak boleh kosong');
    }

    // Validasi nomor pertemuan positif
    if (presensi.pertemuanKe <= 0) {
      return const Result.failed('Nomor pertemuan harus positif');
    }

    return const Result.success(null);
  }

  /// Menghitung summary dari daftar hadir
  PresensiSummary _generateSummary(List<SantriPresensi> daftarHadir) {
    int hadir = 0, sakit = 0, izin = 0, alpha = 0;

    for (var santri in daftarHadir) {
      switch (santri.status) {
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

    return PresensiSummary(
        totalSantri: daftarHadir.length,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

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

      // Gunakan transaction untuk atomic operation
      await _firestore.runTransaction((transaction) async {
        transaction.set(documentReference, presensiData);
      });

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
}
