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
      // 1. Validasi nama program
      if (!['TAHFIDZ', 'GMM', 'IFIS'].contains(program.nama)) {
        return const Result.failed('Nama program tidak valid');
      }

      // 2. Set up document reference dengan nama program sebagai ID
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.collection('program').doc(program.nama);

      // 3. Cek apakah program sudah ada untuk prevent duplicate
      final existingDoc = await documentReference.get();
      if (existingDoc.exists) {
        return Result.failed('Program ${program.nama} sudah ada');
      }

      // 4. Validasi data program
      if (!program.isValidProgram) {
        return const Result.failed('Data program tidak valid');
      }

      // 5. Prepare data untuk firestore dengan timestamps
      final programData = {
        ...program.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'pengajarIds': program.pengajarIds,
        'pengajarNames': program.pengajarNames,
        'enrolledSantriIds': [],
      };

      // 6. Create program dengan transaction untuk atomicity
      await _firestore.runTransaction((transaction) async {
        // Setup collections terkait
        await _setupProgramCollections(program.nama);

        // Create program document
        transaction.set(documentReference, programData);
      });

      // 7. Verify creation dan return hasil
      DocumentSnapshot<Map<String, dynamic>> result =
          await documentReference.get();
      if (result.exists) {
        final data = result.data()!;

        // Convert timestamps ke DateTime
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

// Helper method untuk setup collections terkait program
  Future<void> _setupProgramCollections(String programId) async {
    try {
      final batch = _firestore.batch();

      // Setup presensi collection
      final presensiDoc =
          _firestore.collection('program/$programId/presensi').doc('initial');
      batch.set(presensiDoc,
          {'initialized': true, 'createdAt': FieldValue.serverTimestamp()});

      // Setup progres hafalan collection jika program Tahfidz atau GMM
      if (['TAHFIDZ', 'GMM'].contains(programId)) {
        final progresDoc = _firestore
            .collection('program/$programId/progres_hafalan')
            .doc('initial');
        batch.set(progresDoc,
            {'initialized': true, 'createdAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error setting up program collections: $e');
      rethrow; // Re-throw untuk ditangani di createProgram
    }
  }

  @override
  Future<Result<Program>> getProgramById(String programId) async {
    try {
      // 1. Validasi input
      if (programId.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // 2. Get program document dengan error handling yang robust
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('program').doc(programId).get();

      if (!doc.exists) {
        return Result.failed('Program dengan ID: $programId tidak ditemukan');
      }

      // 3. Validasi dan ekstraksi data
      final data = doc.data()!;
      if (_isInvalidProgramData(data)) {
        debugPrint('Invalid program data structure for ID: $programId');
        return const Result.failed('Data program tidak valid atau rusak');
      }

      // 4. Konversi timestamps dengan null safety
      final convertedData = await _convertProgramTimestamps(data);

      // 5. Pastikan format jadwal valid
      if (data['jadwal'] is List) {
        convertedData['jadwal'] =
            (data['jadwal'] as List).map((e) => e.toString()).toList();
      }

      // 6. Validasi dan konversi list data
      convertedData['pengajarIds'] =
          List<String>.from(data['pengajarIds'] ?? []);
      convertedData['pengajarNames'] =
          List<String>.from(data['pengajarNames'] ?? []);
      convertedData['enrolledSantriIds'] =
          List<String>.from(data['enrolledSantriIds'] ?? []);

      // 7. Create dan return Program entity
      return Result.success(Program.fromJson(convertedData));
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting program: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Unexpected error getting program: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

// Helper untuk validasi struktur data program
  bool _isInvalidProgramData(Map<String, dynamic> data) {
    return data['nama'] == null ||
        data['deskripsi'] == null ||
        data['jadwal'] == null ||
        data['jadwal'] is! List ||
        !_isValidProgramName(data['nama']);
  }

// Helper static method untuk validasi nama program
  bool _isValidProgramName(String nama) {
    return ['TAHFIDZ', 'GMM', 'IFIS'].contains(nama.toUpperCase());
  }

// Helper untuk konversi timestamps
  Future<Map<String, dynamic>> _convertProgramTimestamps(
      Map<String, dynamic> data) async {
    try {
      final convertedData = Map<String, dynamic>.from(data);

      // Convert created/updated timestamps
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

      convertedData['createdAt'] = createdAt?.toIso8601String();
      convertedData['updatedAt'] = updatedAt?.toIso8601String();

      return convertedData;
    } catch (e) {
      debugPrint('Error converting timestamps: $e');
      rethrow;
    }
  }

  @override
  Future<Result<Program>> updateProgram(Program program) async {
    try {
      // 1. Validasi ID program
      if (program.id.isEmpty) {
        return const Result.failed('ID Program tidak boleh kosong');
      }

      // 2. Get document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('program/${program.id}');

      // 3. Validasi program default
      if (['TAHFIDZ', 'GMM', 'IFIS'].contains(program.id)) {
        // Cek perubahan nama program default
        DocumentSnapshot<Map<String, dynamic>> existingDoc =
            await documentReference.get();
        if (existingDoc.exists && existingDoc.data()?['nama'] != program.nama) {
          return const Result.failed('Nama program default tidak dapat diubah');
        }
      }

      // 4. Run atomic update dengan transaction
      return await _firestore
          .runTransaction<Result<Program>>((transaction) async {
        // Get fresh data
        final docSnapshot = await transaction.get(documentReference);
        if (!docSnapshot.exists) {
          return const Result.failed('Program tidak ditemukan');
        }

        // Prepare update data
        final updateData = {
          ...program.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Preserve createdAt
        updateData.remove('createdAt');

        // Validasi data sebelum update
        if (!_validateUpdateData(updateData)) {
          return const Result.failed('Data update tidak valid');
        }

        // Perform update
        transaction.update(documentReference, updateData);

        // Get updated document
        final updatedDoc = await documentReference.get();
        final data = updatedDoc.data()!;

        // Convert timestamps
        final convertedData = await _convertProgramTimestamps(data);

        return Result.success(Program.fromJson(convertedData));
      });
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating program: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Unexpected error updating program: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

// Helper untuk validasi data update
  bool _validateUpdateData(Map<String, dynamic> data) {
    // Required fields harus ada
    if (data['nama'] == null ||
        data['deskripsi'] == null ||
        data['jadwal'] == null) {
      return false;
    }

    // Validasi jadwal
    if (data['jadwal'] is! List || (data['jadwal'] as List).isEmpty) {
      return false;
    }

    // Validasi nama program
    if (!_isValidProgramName(data['nama'])) {
      return false;
    }

    // Validasi list fields
    try {
      List.from(data['pengajarIds'] ?? []);
      List.from(data['pengajarNames'] ?? []);
      List.from(data['enrolledSantriIds'] ?? []);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<List<Program>>> getAllPrograms() async {
    try {
      // 1. Query semua program
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('program').get();

      if (querySnapshot.docs.isEmpty) {
        return const Result.failed('Tidak ada program yang tersedia');
      }

      // 2. Process documents
      List<Program> programs = [];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Convert timestamps
          final convertedData = await _convertProgramTimestamps(data);

          // Convert list fields dengan null safety
          convertedData['pengajarIds'] =
              List<String>.from(data['pengajarIds'] ?? []);
          convertedData['pengajarNames'] =
              List<String>.from(data['pengajarNames'] ?? []);
          convertedData['jadwal'] = List<String>.from(data['jadwal'] ?? []);
          convertedData['enrolledSantriIds'] =
              List<String>.from(data['enrolledSantriIds'] ?? []);

          // Validasi data sebelum konversi ke entity
          if (!_validateProgramData(convertedData)) {
            debugPrint('Invalid program data found for ID: ${doc.id}');
            continue; // Skip invalid data
          }

          programs.add(Program.fromJson(convertedData));
        } catch (e) {
          debugPrint('Error processing program document ${doc.id}: $e');
          continue; // Skip dokumen yang error
        }
      }

      if (programs.isEmpty) {
        return const Result.failed('Tidak ada program valid yang tersedia');
      }

      // 3. Sort programs berdasarkan prioritas
      programs.sort((a, b) {
        // Program default (TAHFIDZ, GMM, IFIS) di atas
        final defaultPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
        final aIsDefault = defaultPrograms.contains(a.nama);
        final bIsDefault = defaultPrograms.contains(b.nama);

        if (aIsDefault && !bIsDefault) return -1;
        if (!aIsDefault && bIsDefault) return 1;

        // Sort berdasarkan nama untuk program non-default
        return a.nama.compareTo(b.nama);
      });

      return Result.success(programs);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting programs: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Unexpected error getting programs: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

// Helper untuk validasi data program
  bool _validateProgramData(Map<String, dynamic> data) {
    // Validasi field required
    if (data['nama'] == null ||
        data['deskripsi'] == null ||
        data['jadwal'] == null) {
      return false;
    }

    // Validasi nama program
    if (!_isValidProgramName(data['nama'])) {
      return false;
    }

    // Validasi jadwal
    if (data['jadwal'] is! List || (data['jadwal'] as List).isEmpty) {
      return false;
    }

    // Validasi list fields
    try {
      List.from(data['pengajarIds'] ?? []);
      List.from(data['pengajarNames'] ?? []);
      List.from(data['enrolledSantriIds'] ?? []);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<List<Program>>> getProgramsByUserId(String userId) async {
    try {
      // 1. Validasi input
      if (userId.isEmpty) {
        return const Result.failed('ID User tidak boleh kosong');
      }

      // 2. Get user doc untuk mendapatkan program IDs
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Result.failed('User dengan ID: $userId tidak ditemukan');
      }

      // 3. Extract program IDs dari user document
      List<String> programIds =
          List<String>.from(userDoc.data()?['programs'] ?? []);

      if (programIds.isEmpty) {
        return const Result.failed('User tidak terdaftar di program manapun');
      }

      // 4. Get program documents dengan batching untuk efisiensi
      List<Program> programs = [];

      // Process dalam batch untuk menghindari terlalu banyak concurrent requests
      for (var i = 0; i < programIds.length; i += 10) {
        final batch = programIds.skip(i).take(10);

        final snapshots = await Future.wait(
            batch.map((id) => _firestore.collection('program').doc(id).get()));

        for (var doc in snapshots) {
          if (!doc.exists) continue;

          try {
            final data = doc.data()!;

            // Convert data
            final convertedData = await _convertProgramTimestamps(data);

            // Convert list fields dengan null safety
            convertedData['pengajarIds'] =
                List<String>.from(data['pengajarIds'] ?? []);
            convertedData['pengajarNames'] =
                List<String>.from(data['pengajarNames'] ?? []);
            convertedData['jadwal'] = List<String>.from(data['jadwal'] ?? []);
            convertedData['enrolledSantriIds'] =
                List<String>.from(data['enrolledSantriIds'] ?? []);

            // Validasi sebelum konversi ke entity
            if (!_validateProgramData(convertedData)) {
              debugPrint('Invalid program data found for ID: ${doc.id}');
              continue;
            }

            programs.add(Program.fromJson(convertedData));
          } catch (e) {
            debugPrint('Error processing program ${doc.id}: $e');
            continue;
          }
        }
      }

      if (programs.isEmpty) {
        return const Result.failed(
            'Tidak dapat menemukan program yang terdaftar');
      }

      // 5. Sort programs
      programs.sort((a, b) {
        // Default programs first
        final defaultPrograms = ['TAHFIDZ', 'GMM', 'IFIS'];
        final aIsDefault = defaultPrograms.contains(a.nama);
        final bIsDefault = defaultPrograms.contains(b.nama);

        if (aIsDefault && !bIsDefault) return -1;
        if (!aIsDefault && bIsDefault) return 1;

        // Then by nama
        return a.nama.compareTo(b.nama);
      });

      return Result.success(programs);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting user programs: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Error getting user programs: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteProgram(String programId) async {
    try {
      // 1. Validasi program default
      if (['TAHFIDZ', 'GMM', 'IFIS'].contains(programId)) {
        return const Result.failed('Program default tidak dapat dihapus');
      }

      // 2. Get document reference
      DocumentReference<Map<String, dynamic>> documentReference =
          _firestore.doc('program/$programId');

      // 3. Cek program exists
      final doc = await documentReference.get();
      if (!doc.exists) {
        return const Result.failed('Program tidak ditemukan');
      }

      // 4. Cek apakah ada santri yang terdaftar
      final userSnapshot = await _firestore
          .collection('users')
          .where('programs', arrayContains: programId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return const Result.failed(
            'Program tidak dapat dihapus karena masih memiliki santri terdaftar');
      }

      // 5. Delete program
      await documentReference.delete();

      // 6. Verify deletion
      final verifyDoc = await documentReference.get();
      if (!verifyDoc.exists) {
        return const Result.success(null);
      } else {
        return const Result.failed('Gagal menghapus program');
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting program: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Error deleting program: $e');
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

      // 2. Convert timestamps and validate data
      final convertedData = await _convertProgramTimestamps(programData);
      if (!_validateProgramData(convertedData)) {
        return const Result.failed('Data program tidak valid');
      }

      // 3. Parse program data ke ProgramDetail
      final program = ProgramDetail.fromJson({
        ...convertedData,
        'id': programId,
        'name': programData['nama'],
        'description': programData['deskripsi'],
        'schedule': List<String>.from(programData['jadwal'] ?? []),
        'totalMeetings': programData['totalPertemuan'] ?? 0,
        'location': programData['lokasi'],
        'teacherIds': List<String>.from(programData['pengajarIds'] ?? []),
        'teacherNames': List<String>.from(programData['pengajarNames'] ?? []),
        'enrolledSantriIds':
            List<String>.from(programData['enrolledSantriIds'] ?? []),
      });

      // 4. Get presensi data untuk statistik
      final presensiQuery = await _firestore
          .collection('presensi')
          .where('programId', isEqualTo: programId)
          .get();

      // 5. Jika belum ada presensi, return default summary
      if (presensiQuery.docs.isEmpty) {
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

      // 6. Calculate presensi summary
      int hadir = 0, sakit = 0, izin = 0, alpha = 0;
      for (var doc in presensiQuery.docs) {
        final data = doc.data();
        List<Map<String, dynamic>> daftarHadir =
            List<Map<String, dynamic>>.from(data['daftarHadir'] ?? []);

        // Find santri presensi data
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

      // 7. Create PresensiSummary
      final summary = PresensiSummary(
        totalSantri: presensiQuery.docs.length,
        hadir: hadir,
        sakit: sakit,
        izin: izin,
        alpha: alpha,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Result.success((program, summary));
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting program details: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Error getting program details: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> validateProgramCombination(
      List<String> programIds) async {
    try {
      // 1. Basic validation
      if (programIds.isEmpty) {
        return const Result.failed('Pilih minimal 1 program');
      }

      if (programIds.length > 3) {
        return const Result.failed('Maksimal pilih 3 program');
      }

      // 2. Validate valid programs
      for (String programId in programIds) {
        if (!_isValidProgramName(programId)) {
          return Result.failed('Program $programId tidak valid');
        }
      }

      // 3. Check for duplicates dengan Set
      if (programIds.toSet().length != programIds.length) {
        return const Result.failed('Program tidak boleh duplikat');
      }

      // 4. Validasi kombinasi program yang tidak diperbolehkan
      // GMM dan IFIS tidak bisa diambil bersamaan
      if (programIds.contains('GMM') && programIds.contains('IFIS')) {
        return const Result.failed(
            'Program GMM dan IFIS tidak dapat diambil bersamaan. Silahkan pilih salah satu.');
      }

      // 5. Verifikasi keberadaan program di Firestore
      try {
        await Future.wait(programIds.map((id) async {
          final docSnapshot =
              await _firestore.collection('program').doc(id).get();
          if (!docSnapshot.exists) {
            throw Exception('Program $id tidak ditemukan di database');
          }

          // Validasi status program
          final data = docSnapshot.data()!;
          if (data['isActive'] == false) {
            throw Exception('Program $id sedang tidak aktif');
          }
        }));
      } catch (e) {
        return Result.failed(e.toString());
      }

      // 6. Cek kapasitas program (jika ada batasan)
      for (String programId in programIds) {
        final doc = await _firestore.collection('program').doc(programId).get();
        final data = doc.data()!;

        final enrolledSantriIds =
            List<String>.from(data['enrolledSantriIds'] ?? []);
        // Contoh batasan: maksimal 30 santri per program
        if (enrolledSantriIds.length >= 30) {
          return Result.failed(
              'Program $programId sudah mencapai kapasitas maksimal');
        }
      }

      debugPrint('Program combination validated successfully: $programIds');
      return const Result.success(true);
    } catch (e) {
      debugPrint('Error validating program combination: $e');
      return Result.failed(
          'Gagal memvalidasi kombinasi program: ${e.toString()}');
    }
  }

  @override
  Future<Result<Program>> addTeacherToProgram({
    required String programId,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      // 1. Validasi input
      if (programId.isEmpty || teacherId.isEmpty || teacherName.isEmpty) {
        return const Result.failed('Semua parameter harus diisi');
      }

      // 2. Reference ke program document
      final programRef = _firestore.collection('program').doc(programId);

      // 3. Atomic update dengan transaction
      return await _firestore
          .runTransaction<Result<Program>>((transaction) async {
        // Get current program data
        final programDoc = await transaction.get(programRef);
        if (!programDoc.exists) {
          return Result.failed('Program dengan ID: $programId tidak ditemukan');
        }

        final currentData = programDoc.data()!;

        // Convert existing teacher lists dengan null safety
        List<String> currentTeacherIds =
            List<String>.from(currentData['pengajarIds'] ?? []);
        List<String> currentTeacherNames =
            List<String>.from(currentData['pengajarNames'] ?? []);

        // 4. Validasi penambahan teacher
        if (currentTeacherIds.length >= Program.maxTeachers) {
          return const Result.failed(
              'Program sudah mencapai batas maksimal ${Program.maxTeachers} pengajar');
        }

        if (currentTeacherIds.contains(teacherId)) {
          return const Result.failed('Pengajar sudah terdaftar di program ini');
        }

        // 5. Update arrays
        currentTeacherIds.add(teacherId);
        currentTeacherNames.add(teacherName);

        // 6. Prepare update data
        final updateData = {
          'pengajarIds': currentTeacherIds,
          'pengajarNames': currentTeacherNames,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // 7. Perform update
        transaction.update(programRef, updateData);

        // 8. Get updated program data
        final updatedDoc = await programRef.get();
        if (!updatedDoc.exists) {
          return const Result.failed(
              'Gagal mendapatkan data program yang diupdate');
        }

        final updatedData = updatedDoc.data()!;

        // Convert timestamps dan validate
        final convertedData = await _convertProgramTimestamps(updatedData);
        if (!_validateProgramData(convertedData)) {
          return const Result.failed('Data program hasil update tidak valid');
        }

        // Return updated program
        return Result.success(Program.fromJson(convertedData));
      });
    } on FirebaseException catch (e) {
      debugPrint('Firebase error adding teacher: ${e.message}');
      return Result.failed('Firebase Error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Error adding teacher to program: $e');
      return Result.failed('Error: ${e.toString()}');
    }
  }

  // @override
  // Future<Result<List<Program>>> getAvailablePrograms() async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('program')
  //         .where('nama', whereIn: ['TAHFIDZ', 'GMM', 'IFIS']).get();

  //     if (querySnapshot.docs.isEmpty) {
  //       return const Result.failed('Program belum diinisialisasi');
  //     }

  //     final programs = querySnapshot.docs.map((doc) {
  //       final data = doc.data();
  //       return Program.fromJson(data);
  //     }).toList();

  //     // Sort berdasarkan urutan tetap
  //     programs.sort((a, b) {
  //       final order = {'TAHFIDZ': 1, 'GMM': 2, 'IFIS': 3};
  //       return (order[a.nama] ?? 4).compareTo(order[b.nama] ?? 4);
  //     });

  //     return Result.success(programs);
  //   } catch (e) {
  //     debugPrint('Error getting available programs: $e');
  //     return Result.failed('Gagal mengambil daftar program: ${e.toString()}');
  //   }
  // }

  // @override
  // Future<Result<Program>> activateProgram(String programId) {
  //   // TODO: implement activateProgram
  //   throw UnimplementedError();
  // }

  // @override
  // Future<Result<bool>> canAddTeacher(
  //     {required String programId, required String teacherId}) {
  //   // TODO: implement canAddTeacher
  //   throw UnimplementedError();
  // }

  // @override
  // Future<Result<Program>> deactivateProgram(String programId) {
  //   // TODO: implement deactivateProgram
  //   throw UnimplementedError();
  // }

  // @override
  // Future<Result<List<String>>> getProgramTeachers(String programId) {
  //   // TODO: implement getProgramTeachers
  //   throw UnimplementedError();
  // }

  // @override
  // Future<Result<bool>> isProgramActive(String programId) {
  //   // TODO: implement isProgramActive
  //   throw UnimplementedError();
  // }

  // @override
  // Future<Result<Program>> removeTeacherFromProgram(
  //     {required String programId, required String teacherId}) {
  //   // TODO: implement removeTeacherFromProgram
  //   throw UnimplementedError();
  // }
}
