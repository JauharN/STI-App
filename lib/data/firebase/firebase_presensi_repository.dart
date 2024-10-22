import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/result.dart';
import '../../domain/entities/presensi.dart';
import '../repositories/presensi_repository.dart';

class FirebasePresensiRepository implements PresensiRepository {
  final FirebaseFirestore _firestore;

  FirebasePresensiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Presensi>> createPresensi(Presensi presensi) async {
    try {
      // Validasi program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(presensi.programId)) {
        return const Result.failed('Invalid program ID');
      }

      // Validasi status
      if (!['HADIR', 'IZIN', 'SAKIT', 'ALPHA'].contains(presensi.status)) {
        return const Result.failed('Invalid status');
      }

      // Membuat referensi dokumen baru
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('presensi').doc();

      // Data yang akan disimpan
      final presensiData = {
        ...presensi.toJson(),
        'id': documentReference.id, // Tambahkan ID dokumen
        'createdAt': FieldValue.serverTimestamp(), // Tambahkan timestamp
      };

      // Simpan ke Firestore
      await documentReference.set(presensiData);

      // Ambil data untuk verifikasi
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        Presensi createdPresensi = Presensi.fromJson(result.data()!);
        return Result.success(createdPresensi);
      } else {
        return const Result.failed('Failed to create presensi');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create presensi');
    }
  }

  @override
  Future<Result<List<Presensi>>> getPresensiByUserId(String userId) async {
    try {
      // Query untuk mengambil semua presensi seorang user
      // Diurutkan berdasarkan tanggal terbaru
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('presensi')
          .where('userId', isEqualTo: userId) // Filter berdasarkan userId
          .orderBy('tanggal', descending: true) // Urutkan berdasarkan tanggal
          .get();

      // Cek apakah ada data presensi
      if (querySnapshot.docs.isNotEmpty) {
        // Konversi semua dokumen menjadi list objek Presensi
        List<Presensi> presensiList = querySnapshot.docs
            .map((doc) => Presensi.fromJson(doc.data()))
            .toList();
        return Result.success(presensiList);
      } else {
        return const Result.failed('No presensi found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get presensi');
    }
  }

  @override
  Future<Result<List<Presensi>>> getPresensiByProgramId(
      String programId) async {
    try {
      // Validasi program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(programId)) {
        return const Result.failed('Invalid program ID');
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .orderBy('tanggal', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Presensi> presensiList = querySnapshot.docs
            .map((doc) => Presensi.fromJson(doc.data()))
            .toList();
        return Result.success(presensiList);
      } else {
        return const Result.failed('No presensi found for this program');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get presensi');
    }
  }

  @override
  Future<Result<Presensi>> updatePresensi(Presensi presensi) async {
    try {
      // Validasi program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(presensi.programId)) {
        return const Result.failed('Invalid program ID');
      }

      // Validasi status
      if (!['HADIR', 'IZIN', 'SAKIT', 'ALPHA'].contains(presensi.status)) {
        return const Result.failed('Invalid status');
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('presensi/${presensi.id}');

      final updateData = {
        ...presensi.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentReference.update(updateData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        Presensi updatedPresensi = Presensi.fromJson(result.data()!);
        if (updatedPresensi.status == presensi.status) {
          return Result.success(updatedPresensi);
        } else {
          return const Result.failed('Failed to update presensi status');
        }
      } else {
        return const Result.failed('Presensi not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update presensi');
    }
  }

  @override
  Future<Result<void>> deletePresensi(String presensiId) async {
    try {
      // Membuat referensi ke dokumen yang akan dihapus
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('presensi/$presensiId');

      // Hapus dokumen
      await documentReference.delete();

      // Verifikasi penghapusan dengan mengecek keberadaan dokumen
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      // Jika dokumen tidak ada lagi, berarti berhasil dihapus
      if (!result.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Failed to delete presensi');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete presensi');
    }
  }
}
