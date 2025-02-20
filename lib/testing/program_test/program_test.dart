import 'package:flutter_test/flutter_test.dart';
import '../../domain/entities/program.dart';

void main() {
  group('Program Entity Tests', () {
    // Test 1: Program creation with valid data
    test('should create valid program with multiple teachers', () {
      final program = Program(
        id: 'TAHFIDZ',
        nama: 'TAHFIDZ',
        deskripsi: 'Program Tahfidz Al-Quran',
        jadwal: ['Senin', 'Rabu', 'Jumat'],
        lokasi: 'Ruang Tahfidz',
        pengajarIds: ['teacher1', 'teacher2'],
        pengajarNames: ['Ustadz Ahmad', 'Ustadz Mahmud'],
        kelas: 'Reguler',
        totalPertemuan: 8,
      );

      expect(program.nama, 'TAHFIDZ');
      expect(program.pengajarIds.length, 2);
      expect(program.isValidProgram, true);
    });

    // Test 2: Check max teachers validation
    test('should validate max teachers limit', () {
      final program = Program(
        id: 'TAHFIDZ',
        nama: 'TAHFIDZ',
        deskripsi: 'Program Tahfidz Al-Quran',
        jadwal: ['Senin'],
        pengajarIds: ['teacher1', 'teacher2', 'teacher3'],
        pengajarNames: ['Ustadz A', 'Ustadz B', 'Ustadz C'],
      );

      expect(program.canAddMoreTeachers, false); // Karena sudah 3 guru
      expect(program.isValidTeacherAddition('teacher4'), false);
    });

    // Test 3: Check program name validation
    test('should validate program name', () {
      expect(Program.isValidProgramName('TAHFIDZ'), true);
      expect(Program.isValidProgramName('GMM'), true);
      expect(Program.isValidProgramName('IFIS'), true);
      expect(Program.isValidProgramName('INVALID'), false);
    });

    // Test 4: Check jadwal validation
    test('should validate jadwal format', () {
      final program = Program(
        id: 'GMM',
        nama: 'GMM',
        deskripsi: 'Program GMM',
        jadwal: ['Senin', 'Selasa'],
      );

      expect(program.isValidSchedule(['Senin', 'Selasa']), true);
      expect(program.isValidSchedule(['Invalid', 'Day']), false);
    });

    // Test 5: Check teacher operations
    test('should handle teacher operations correctly', () {
      final program = Program(
        id: 'IFIS',
        nama: 'IFIS',
        deskripsi: 'Program IFIS',
        jadwal: ['Senin'],
        pengajarIds: ['teacher1'],
        pengajarNames: ['Ustadz A'],
      );

      expect(program.hasTeachers, true);
      expect(program.hasTeacher('teacher1'), true);
      expect(program.hasTeacher('nonexistent'), false);
      expect(program.canAddMoreTeachers, true); // Karena baru 1 guru
    });
  });
}
