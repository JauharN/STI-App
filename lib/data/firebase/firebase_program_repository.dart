import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sti_app/domain/entities/presensi/presensi_summary.dart';
import 'package:sti_app/domain/entities/presensi/program_detail.dart';
import '../repositories/program_repository.dart';
import '../../domain/entities/program.dart';
import '../../domain/entities/result.dart';

class FirebaseProgramRepository implements ProgramRepository {
  final FirebaseFirestore _firestore;

  FirebaseProgramRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Program>> createProgram(Program program) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('program').doc(program.nama);

      // Validasi nama program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(program.nama)) {
        return const Result.failed('Nama program tidak valid');
      }

      final programData = {
        ...program.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentReference.set(programData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        final data = result.data()!;
        // Convert timestamps to DateTime
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        return Result.success(Program.fromJson({
          ...data,
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        }));
      } else {
        return const Result.failed('Gagal membuat program');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteProgram(String programId) async {
    try {
      // Validasi program default
      final defaultPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
      if (defaultPrograms.contains(programId)) {
        return const Result.failed('Program default tidak dapat dihapus');
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('program/$programId');

      // Cek program exists
      final doc = await documentReference.get();
      if (!doc.exists) {
        return const Result.failed('Program tidak ditemukan');
      }

      // Cek apakah ada santri yang terdaftar
      final userSnapshot = await _firestore
          .collection('users')
          .where('programs', arrayContains: programId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return const Result.failed(
            'Program tidak dapat dihapus karena masih memiliki santri terdaftar');
      }

      // Delete program
      await documentReference.delete();

      // Verify deletion
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();
      if (!result.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Gagal menghapus program');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Program>>> getAllPrograms() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('program').get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.failed('Tidak ada program yang tersedia');
      }

      List<Program> programs = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Convert timestamps
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        programs.add(Program.fromJson({
          ...data,
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        }));
      }

      // Sort by default programs first
      programs.sort((a, b) {
        final defaultPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
        final aIsDefault = defaultPrograms.contains(a.nama);
        final bIsDefault = defaultPrograms.contains(b.nama);

        if (aIsDefault && !bIsDefault) return -1;
        if (!aIsDefault && bIsDefault) return 1;
        return a.nama.compareTo(b.nama);
      });

      return Result.success(programs);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<Program>> getProgramById(String programId) async {
    try {
      if (programId.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('program').doc(programId).get();

      if (!doc.exists) {
        return Result.failed('Program dengan ID: $programId tidak ditemukan');
      }

      // Validasi data
      final data = doc.data()!;
      if (data['nama'] == null ||
          data['deskripsi'] == null ||
          data['jadwal'] == null) {
        return const Result.failed('Data program tidak valid');
      }

      // Convert timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

      // Pastikan jadwal adalah List<String>
      if (data['jadwal'] is List) {
        data['jadwal'] =
            (data['jadwal'] as List).map((e) => e.toString()).toList();
      }

      return Result.success(Program.fromJson({
        ...data,
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
  Future<Result<List<Program>>> getProgramsByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        return const Result.failed('ID User tidak boleh kosong');
      }

      // Get user doc untuk mendapatkan program IDs
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Result.failed('User dengan ID: $userId tidak ditemukan');
      }

      // Get array program IDs
      List<String> programIds =
          List<String>.from(userDoc.data()?['programs'] ?? []);

      if (programIds.isEmpty) {
        return const Result.failed('User tidak terdaftar di program manapun');
      }

      List<Program> programs = [];
      for (String programId in programIds) {
        DocumentSnapshot<Map<String, dynamic>> programDoc =
            await _firestore.collection('program').doc(programId).get();

        if (programDoc.exists) {
          final data = programDoc.data()!;

          // Convert timestamps
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

          // Pastikan jadwal adalah List<String>
          if (data['jadwal'] is List) {
            data['jadwal'] =
                (data['jadwal'] as List).map((e) => e.toString()).toList();
          }

          programs.add(Program.fromJson({
            ...data,
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
          }));
        }
      }

      if (programs.isEmpty) {
        return const Result.failed(
            'Tidak dapat menemukan program yang terdaftar');
      }

      return Result.success(programs);
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<Program>> updateProgram(Program program) async {
    try {
      if (program.id.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // Validasi program default
      if (['TAHFIDZ', 'GMM', 'IFIS'].contains(program.id)) {
        // Cek perubahan nama program default
        DocumentSnapshot<Map<String, dynamic>> existingDoc =
            await _firestore.doc('program/${program.id}').get();

        if (existingDoc.exists && existingDoc.data()?['nama'] != program.nama) {
          return const Result.failed('Nama program default tidak dapat diubah');
        }
      }

      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('programs/${program.id}');

      final updateData = {
        ...program.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove createdAt from update data
      updateData.remove('createdAt');

      await documentReference.update(updateData);

      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();

      if (result.exists) {
        final data = result.data()!;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        return Result.success(Program.fromJson({
          ...data,
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
        }));
      } else {
        return const Result.failed('Program tidak ditemukan');
      }
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<(ProgramDetail, PresensiSummary)>> getProgramDetailWithStats({
    required String programId,
    required String requestingUserId,
  }) async {
    try {
      // 1. Get program detail
      final programDoc =
          await _firestore.collection('program').doc(programId).get();

      if (!programDoc.exists) {
        return const Result.failed('Program tidak ditemukan');
      }

      final programData = programDoc.data()!;

      // Convert timestamps
      final createdAt = (programData['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (programData['updatedAt'] as Timestamp?)?.toDate();

      // Parse program data
      final program = ProgramDetail.fromJson({
        ...programData,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      });

      // 2. Get presensi data query
      final presensiQuery = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .get();

      if (presensiQuery.docs.isEmpty) {
        // Return program dengan summary default
        return Result.success((
          program,
          PresensiSummary(
            totalSantri: program.enrolledSantriIds.length,
            hadir: 0,
            sakit: 0,
            izin: 0,
            alpha: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        ));
      }

      // 3. Calculate summary
      int hadir = 0, sakit = 0, izin = 0, alpha = 0;

      for (var doc in presensiQuery.docs) {
        final data = doc.data();
        List<Map<String, dynamic>> daftarHadir =
            List<Map<String, dynamic>>.from(data['daftarHadir'] ?? []);

        // Find santri data
        var santriData = daftarHadir.firstWhere(
          (p) => p['santriId'] == requestingUserId,
          orElse: () => {
            'santriId': requestingUserId,
            'status': 'alpha',
            'keterangan': 'Tidak hadir'
          },
        );

        // Count status
        switch (santriData['status'].toString().toUpperCase()) {
          case 'HADIR':
            hadir++;
            break;
          case 'SAKIT':
            sakit++;
            break;
          case 'IZIN':
            izin++;
            break;
          case 'ALPHA':
            alpha++;
            break;
        }
      }

      // Create PresensiSummary
      final summary = PresensiSummary(
        totalSantri: presensiQuery.docs.length,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 4. Return combined result
      return Result.success((program, summary));
    } on FirebaseException catch (e) {
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Program>>> getAvailablePrograms() async {
    try {
      final querySnapshot = await _firestore
          .collection('program')
          .where('nama', whereIn: ['TAHFIDZ', 'GMM', 'IFIS']).get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.failed('Program belum diinisialisasi');
      }

      final programs = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Program.fromJson(data);
      }).toList();

      // Sort berdasarkan urutan tetap
      programs.sort((a, b) {
        final order = {'TAHFIDZ': 1, 'GMM': 2, 'IFIS': 3};
        return (order[a.nama] ?? 4).compareTo(order[b.nama] ?? 4);
      });

      return Result.success(programs);
    } catch (e) {
      debugPrint('Error getting available programs: $e');
      return Result.failed('Gagal mengambil daftar program: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> validateProgramCombination(
      List<String> programIds) async {
    try {
      // Basic validation
      if (programIds.isEmpty) {
        return const Result.failed('Pilih minimal 1 program');
      }

      if (programIds.length > 3) {
        return const Result.failed('Maksimal pilih 3 program');
      }

      // Validate valid programs
      for (String programId in programIds) {
        if (!ProgramRepository.isValidProgram(programId)) {
          return Result.failed('Program $programId tidak valid');
        }
      }

      // Check for duplicates
      if (programIds.toSet().length != programIds.length) {
        return const Result.failed('Program tidak boleh duplikat');
      }

      // Validasi kombinasi program
      if (!ProgramRepository.isValidCombination(programIds)) {
        return const Result.failed(
            'Program GMM dan IFIS tidak dapat diambil bersamaan');
      }

      // Tambahkan urutan validasi yang lebih detail
      if (programIds.contains('GMM') && programIds.contains('IFIS')) {
        return const Result.failed(
            'Program GMM dan IFIS tidak dapat diambil bersamaan. Silahkan pilih salah satu.');
      }

      debugPrint('Validating program combination: $programIds');

      // Verifikasi program exists di Firestore
      for (String programId in programIds) {
        final docSnapshot =
            await _firestore.collection('program').doc(programId).get();

        if (!docSnapshot.exists) {
          return Result.failed('Program $programId tidak ditemukan');
        }
      }

      return const Result.success(true);
    } catch (e) {
      debugPrint('Error validating program combination: $e');
      return Result.failed(
          'Gagal memvalidasi kombinasi program: ${e.toString()}');
    }
  }
}
