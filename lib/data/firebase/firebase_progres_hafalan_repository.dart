import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Memvalidasi apakah programId sesuai (hanya TAHFIDZ atau GMM)
      if (!['TAHFIDZ', 'GMM'].contains(progresHafalan.programId)) {
        return const Result.failed('Invalid program ID');
      }

      // Validasi kelengkapan data berdasarkan jenis program
      // Untuk TAHFIDZ harus ada juz, halaman, dan ayat
      // Untuk GMM harus ada iqroLevel, iqroHalaman, dan mutabaahTarget
      if (progresHafalan.programId == 'TAHFIDZ') {
        if (progresHafalan.juz == null ||
            progresHafalan.halaman == null ||
            progresHafalan.ayat == null) {
          return const Result.failed('Incomplete Tahfidz progress data');
        }
      } else if (progresHafalan.programId == 'GMM') {
        if (progresHafalan.iqroLevel == null ||
            progresHafalan.iqroHalaman == null ||
            progresHafalan.mutabaahTarget == null) {
          return const Result.failed('Incomplete GMM progress data');
        }
      }

      // Membuat referensi dokumen baru dengan ID otomatis
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('progres_hafalan').doc();

      // Menyiapkan data yang akan disimpan
      // Termasuk ID dokumen dan timestamp pembuatan
      final progresData = {
        ...progresHafalan.toJson(),
        'id': documentReference.id,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Menghapus field yang tidak relevan berdasarkan jenis program
      // TAHFIDZ tidak butuh field GMM dan sebaliknya
      if (progresHafalan.programId == 'TAHFIDZ') {
        progresData.remove('iqroLevel');
        progresData.remove('iqroHalaman');
        progresData.remove('mutabaahTarget');
      } else {
        progresData.remove('juz');
        progresData.remove('halaman');
        progresData.remove('ayat');
      }

      // Menyimpan data ke Firestore
      await documentReference.set(progresData);

      // Mengambil dan memverifikasi data yang baru disimpan
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(ProgresHafalan.fromJson(result.data()!));
      } else {
        return const Result.failed('Failed to create progress');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to create progress');
    }
  }

  @override
  Future<Result<List<ProgresHafalan>>> getProgresHafalanByUserId(
      String userId) async {
    try {
      // Query untuk mengambil semua progres hafalan seorang user
      // Diurutkan berdasarkan tanggal terbaru
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .get();

      // Jika ada data, konversi ke List<ProgresHafalan>
      if (querySnapshot.docs.isNotEmpty) {
        List<ProgresHafalan> progressList = querySnapshot.docs
            .map((doc) => ProgresHafalan.fromJson(doc.data()))
            .toList();
        return Result.success(progressList);
      } else {
        return const Result.failed('No progress found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get progress');
    }
  }

  @override
  Future<Result<ProgresHafalan>> updateProgresHafalan(
      ProgresHafalan progresHafalan) async {
    try {
      // Validasi program ID
      if (!['TAHFIDZ', 'GMM'].contains(progresHafalan.programId)) {
        return const Result.failed('Invalid program ID');
      }

      // Membuat referensi ke dokumen yang akan diupdate
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('progres_hafalan/${progresHafalan.id}');

      // Menyiapkan data update termasuk timestamp
      final updateData = {
        ...progresHafalan.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Menghapus field yang tidak relevan sesuai jenis program
      if (progresHafalan.programId == 'TAHFIDZ') {
        updateData.remove('iqroLevel');
        updateData.remove('iqroHalaman');
        updateData.remove('mutabaahTarget');
      } else {
        updateData.remove('juz');
        updateData.remove('halaman');
        updateData.remove('ayat');
      }

      // Melakukan update data
      await documentReference.update(updateData);

      // Verifikasi hasil update
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        return Result.success(ProgresHafalan.fromJson(result.data()!));
      } else {
        return const Result.failed('Progress not found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to update progress');
    }
  }

  @override
  Future<Result<void>> deleteProgresHafalan(String progresHafalanId) async {
    try {
      // Membuat referensi ke dokumen yang akan dihapus
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('progres_hafalan/$progresHafalanId');

      // Menghapus dokumen
      await documentReference.delete();

      // Verifikasi penghapusan
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      // Jika dokumen tidak ada lagi, berarti berhasil dihapus
      if (!result.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Failed to delete progress');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to delete progress');
    }
  }

  @override
  Future<Result<ProgresHafalan>> getLatestProgresHafalan(String userId) async {
    try {
      // Query untuk mengambil progres hafalan terbaru dari seorang user
      // Menggunakan limit(1) untuk mengambil satu dokumen terbaru saja
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('progres_hafalan')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .limit(1)
          .get();

      // Jika ada data, ambil dokumen pertama (terbaru)
      if (querySnapshot.docs.isNotEmpty) {
        return Result.success(
            ProgresHafalan.fromJson(querySnapshot.docs.first.data()));
      } else {
        return const Result.failed('No progress found');
      }
    } on FirebaseException catch (e) {
      return Result.failed(e.message ?? 'Failed to get latest progress');
    }
  }
}
