import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/program.dart';
import '../../domain/usecase/program/create_program/create_program.dart';
import '../../presentation/utils/logger_util.dart';
import '../repositories/program_repository.dart';

class ProgramInitializer {
  final CreateProgram _createProgram;
  final ProgramRepository _programRepository;
  final FirebaseFirestore _firestore;

  ProgramInitializer({
    required CreateProgram createProgram,
    required ProgramRepository programRepository,
    FirebaseFirestore? firestore,
  })  : _createProgram = createProgram,
        _programRepository = programRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initializeDefaultPrograms() async {
    final defaultPrograms = [
      Program(
        id: 'TAHFIDZ',
        nama: 'TAHFIDZ',
        deskripsi: 'Program Tahfidz Al-Quran',
        jadwal: ['Senin', 'Rabu', 'Jumat'],
        lokasi: 'Ruang Tahfidz',
        pengajarIds: [
          'yZk1pbuY3QZqA4oRw7Wic6wjTrk2', // umai.tahfidz
          'tORqeCIHy7av6ZycrXZnnKQlbwh1', // bagja.tahfidz
          'PjssA7Y295bDxJPgeDO5nKnJGw12', // alia.tahfidz
          'w46Q1ekCj3frtcTbALvQiPS5YSB3', // nada.tahfidz
        ],
        pengajarNames: [
          'Ustadzah Umai',
          'Ustadz Bagja',
          'Ustadzah Alia',
          'Ustadzah Nada',
        ],
        enrolledSantriIds: ['chp06iSzC0afAOQpC2JDgm3WGfI3'], // jauhar22
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Program(
        id: 'GMM',
        nama: 'GMM',
        deskripsi: 'Program Gerakan Maghrib Mengaji',
        jadwal: ['Selasa', 'Kamis', 'Sabtu'],
        lokasi: 'Ruang GMM',
        pengajarIds: [
          'BMSoJS9pCWOabwu3hadWfCzUkWz2', // ajeng.gmm
          'zgXrFf8pikcbfVSwv662sVjx8yr1', // fadhel.gmm
          'LoTeAZencVhEIjbqIW4SqnboQhx1', // aul.gmm
        ],
        pengajarNames: [
          'Ustadzah Ajeng',
          'Ustadz Fadhel',
          'Ustadzah Aul',
        ],
        enrolledSantriIds: ['chp06iSzC0afAOQpC2JDgm3WGfI3'], // jauhar22
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Program(
        id: 'IFIS',
        nama: 'IFIS',
        deskripsi: 'Program Madrasah Diniyah Taqmiliyah Ibnu Farobi',
        jadwal: ['Senin', 'Kamis'],
        lokasi: 'Ruang IFIS',
        pengajarIds: [
          'Uc3BSYjzBZeuHqWwcqRPZDaR32g1', // lina.ifis
          'E1CYPlXNhwSXoNtbcmAY7nYFxm33', // tina.ifis
          'g7Kass4TtndcXZ55Yyu2oAUaCZy1', // wulan.ifis
        ],
        pengajarNames: [
          'Ustadzah Lina',
          'Ustadzah Tina',
          'Ustadzah Wulan',
        ],
        enrolledSantriIds: ['chp06iSzC0afAOQpC2JDgm3WGfI3'], // jauhar22
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var program in defaultPrograms) {
      try {
        final existingProgram = await _checkExistingProgram(program.id);

        if (existingProgram) {
          // Update dengan data lengkap jika sudah ada
          await _updateProgramData(program);
          logger.i('Program ${program.nama} updated with complete data');
        } else {
          // Create baru dengan data lengkap
          final result = await _createNewProgram(program);
          if (result) {
            await _setupProgramCollections(program.id);
            logger.i('Program ${program.nama} created with complete data');
          }
        }
      } catch (e) {
        logger.e('Error initializing ${program.nama}: $e');
      }
    }
  }

  Future<void> _updateProgramData(Program program) async {
    try {
      final updateResult = await _programRepository.updateProgram(program);
      if (!updateResult.isSuccess) {
        logger.e(
            'Failed to update ${program.nama}: ${updateResult.errorMessage}');
      }
    } catch (e) {
      logger.e('Error updating program data: $e');
    }
  }

  Future<bool> _checkExistingProgram(String programId) async {
    final result = await _programRepository.getProgramById(programId);
    return result.isSuccess;
  }

  Future<bool> _createNewProgram(Program program) async {
    try {
      final result = await _createProgram(
        CreateProgramParams(
          nama: program.nama,
          deskripsi: program.deskripsi,
          jadwal: program.jadwal,
          lokasi: program.lokasi,
          currentUserRole: 'superAdmin',
          totalPertemuan: program.totalPertemuan,
          kelas: program.kelas,
          initialTeacherIds: program.pengajarIds, // Ganti nama parameter
          initialTeacherNames: program.pengajarNames, // Ganti nama parameter
          enrolledSantriIds: program.enrolledSantriIds, // Tambahkan ini
        ),
      );

      return result.isSuccess;
    } catch (e) {
      logger.e('Error creating program: $e');
      return false;
    }
  }

  Future<void> _setupProgramCollections(String programId) async {
    try {
      final batch = _firestore.batch();

      // Setup presensi collection
      final presensiDoc =
          _firestore.collection('program/$programId/presensi').doc('initial');
      batch.set(presensiDoc,
          {'initialized': true, 'createdAt': FieldValue.serverTimestamp()});

      // Setup progres collection
      final progresDoc = _firestore
          .collection('program/$programId/progres_hafalan')
          .doc('initial');
      batch.set(progresDoc,
          {'initialized': true, 'createdAt': FieldValue.serverTimestamp()});

      await batch.commit();
      logger.i('Collections setup completed for program: $programId');
    } catch (e) {
      logger.e('Error setting up collections: $e');
    }
  }
}
