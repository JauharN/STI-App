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
        pengajarIds: [],
        pengajarNames: [],
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Program(
        id: 'GMM',
        nama: 'GMM',
        deskripsi: 'Program Generasi Menghafal Mandiri',
        jadwal: ['Selasa', 'Kamis', 'Sabtu'],
        lokasi: 'Ruang GMM',
        pengajarIds: [],
        pengajarNames: [],
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Program(
        id: 'IFIS',
        nama: 'IFIS',
        deskripsi: 'Program Islamic Foundation and Islamic Studies',
        jadwal: ['Senin', 'Kamis'],
        lokasi: 'Ruang IFIS',
        pengajarIds: [],
        pengajarNames: [],
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var program in defaultPrograms) {
      try {
        // Validasi dan cek program existing
        final existingProgram = await _checkExistingProgram(program.id);
        if (existingProgram) {
          await _updateProgram(program);
          continue;
        }

        // Create program baru
        final result = await _createNewProgram(program);

        if (result) {
          await _setupProgramCollections(program.id);
        }
      } catch (e) {
        logger.e('Error initializing ${program.nama}: $e');
      }
    }
  }

  Future<bool> _checkExistingProgram(String programId) async {
    final result = await _programRepository.getProgramById(programId);
    return result.isSuccess;
  }

  Future<void> _updateProgram(Program program) async {
    try {
      final updateResult = await _programRepository.updateProgram(program);
      if (updateResult.isSuccess) {
        logger.i('Updated program: ${program.nama}');
      } else {
        logger.e(
            'Failed to update ${program.nama}: ${updateResult.errorMessage}');
      }
    } catch (e) {
      logger.e('Error updating program: $e');
    }
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
        ),
      );

      if (result.isSuccess) {
        logger.i('Created program: ${program.nama}');
        return true;
      } else {
        logger.e('Failed to create ${program.nama}: ${result.errorMessage}');
        return false;
      }
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
