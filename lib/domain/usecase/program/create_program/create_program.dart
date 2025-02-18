import 'package:flutter/foundation.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/program_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/program.dart';

part 'create_program_params.dart';

class CreateProgram implements Usecase<Result<Program>, CreateProgramParams> {
  final ProgramRepository _programRepository;

  CreateProgram({required ProgramRepository programRepository})
      : _programRepository = programRepository;

  @override
  Future<Result<Program>> call(CreateProgramParams params) async {
    try {
      // Role validation
      if (params.currentUserRole != 'admin' &&
          params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Akses ditolak: Hanya admin atau superAdmin yang dapat membuat program');
      }

      // Program name validation
      if (!Program.isValidProgramName(params.nama)) {
        return Result.failed(
            'Nama program tidak valid: ${params.nama}. Harus TAHFIDZ, GMM, atau IFIS');
      }

      // Required fields validation
      if (params.jadwal.isEmpty) {
        return const Result.failed('Jadwal program tidak boleh kosong');
      }

      if (params.totalPertemuan == null || params.totalPertemuan! <= 0) {
        return const Result.failed('Total pertemuan harus lebih dari 0');
      }

      if (params.kelas?.isEmpty ?? true) {
        return const Result.failed('Kelas tidak boleh kosong');
      }

      // Create program with empty teacher lists initially
      final program = Program(
        id: params.nama.toUpperCase(), // Use program name as ID
        nama: params.nama.toUpperCase(),
        deskripsi: params.deskripsi,
        jadwal: params.jadwal,
        lokasi: params.lokasi,
        pengajarIds: [], // Initialize empty list for multiple teachers
        pengajarNames: [], // Initialize empty list for multiple teachers
        kelas: params.kelas,
        totalPertemuan: params.totalPertemuan,
        enrolledSantriIds: [], // Initialize empty list for santri
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('Creating program with data: ${program.toString()}');

      // Save to repository
      final result = await _programRepository.createProgram(program);

      if (result.isSuccess) {
        debugPrint('Successfully created program: ${program.nama}');
      } else {
        debugPrint('Failed to create program: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error creating program: $e');
      return Result.failed('Gagal membuat program: ${e.toString()}');
    }
  }
}
