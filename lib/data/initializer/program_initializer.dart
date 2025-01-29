import '../../domain/entities/program.dart';
import '../../domain/usecase/program/create_program/create_program.dart';
import '../../presentation/utils/logger_util.dart';
import '../repositories/program_repository.dart';
import '../../domain/entities/user.dart'; // Tambahkan import untuk UserRole

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
        id: 'TAHFIDZ', // ID tetap
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
      // Cek apakah program sudah ada
      final existingProgram =
          await _programRepository.getProgramById(program.id);

      if (existingProgram.isSuccess) {
        logger.i('Program ${program.nama} already exists, skipping...');
        continue;
      }

      // Jika belum ada, buat program baru
      final result = await _createProgram(
        CreateProgramParams(
          nama: program.nama,
          deskripsi: program.deskripsi,
          jadwal: program.jadwal,
          lokasi: program.lokasi,
          currentUserRole: UserRole.superAdmin,
        ),
      );

      if (result.isFailed) {
        logger
            .e('Failed to initialize ${program.nama}: ${result.errorMessage}');
      } else {
        logger.i('Successfully initialized ${program.nama}');
      }
    }
  }
}
