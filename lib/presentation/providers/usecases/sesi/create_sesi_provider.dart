import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sti_app/domain/usecase/sesi/create_sesi/create_sesi.dart';
import 'package:sti_app/presentation/providers/repositories/sesi_repository/sesi_repository_provider.dart';
import 'package:sti_app/presentation/providers/repositories/program_repository/program_repository_provider.dart'; // Tambahkan ini

part 'create_sesi_provider.g.dart';

// Provider untuk membuat sesi pembelajaran baru (khusus admin)
// Digunakan untuk menjadwalkan sesi Tahfidz, GMM, atau IFIS
@riverpod
CreateSesi createSesi(CreateSesiRef ref) => CreateSesi(
      sesiRepository: ref.watch(sesiRepositoryProvider),
      programRepository: ref.watch(programRepositoryProvider), // Tambahkan ini
    );
