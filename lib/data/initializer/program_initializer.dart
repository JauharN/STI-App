// lib/data/initializer/program_initializer.dart

import '../../domain/entities/program.dart';
import '../../domain/usecase/program/create_program/create_program.dart';
import '../../presentation/utils/logger_util.dart';
import '../repositories/program_repository.dart';

class ProgramInitializer {
  final CreateProgram _createProgram;
  final ProgramRepository _programRepository;

  ProgramInitializer({
    required CreateProgram createProgram,
    required ProgramRepository programRepository,
  })  : _createProgram = createProgram,
        _programRepository = programRepository;

  Future<void> initializeDefaultPrograms() async {
    final defaultPrograms = [
      Program(
        id: 'TAHFIDZ',
        nama: 'TAHFIDZ',
        deskripsi: 'Program Tahfidz Al-Quran',
        jadwal: ['Senin', 'Rabu', 'Jumat'],
        lokasi: 'Ruang Tahfidz',
        pengajarId: null,
        pengajarName: null,
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
        pengajarId: null,
        pengajarName: null,
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
        pengajarId: null,
        pengajarName: null,
        kelas: 'Reguler',
        totalPertemuan: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var program in defaultPrograms) {
      try {
        // Cek apakah program sudah ada
        final existingProgram =
            await _programRepository.getProgramById(program.id);

        if (existingProgram.isSuccess) {
          logger
              .i('Program ${program.nama} sudah ada, melewati inisialisasi...');
          continue;
        }

        // Jika belum ada, buat program baru
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

        if (result.isFailed) {
          logger
              .e('Gagal inisialisasi ${program.nama}: ${result.errorMessage}');
        } else {
          logger.i('Berhasil inisialisasi ${program.nama}');
        }
      } catch (e) {
        logger.e('Error saat inisialisasi ${program.nama}: $e');
      }
    }
  }
}
