import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import '../../../entities/user.dart';
import '../../usecase.dart';

part 'delete_presensi_pertemuan_params.dart';

class DeletePresensiPertemuan
    implements Usecase<Result<void>, DeletePresensiPertemuanParams> {
  final PresensiRepository _presensiRepository;

  DeletePresensiPertemuan({
    required PresensiRepository presensiRepository,
  }) : _presensiRepository = presensiRepository;

  @override
  Future<Result<void>> call(DeletePresensiPertemuanParams params) async {
    // Validasi role
    if (params.currentUserRole != UserRole.admin &&
        params.currentUserRole != UserRole.superAdmin) {
      return const Result.failed(
          'Akses ditolak: Hanya admin atau superAdmin yang dapat menghapus presensi.');
    }

    try {
      return await _presensiRepository.deletePresensiPertemuan(params.id);
    } catch (e) {
      return Result.failed('Gagal menghapus presensi: ${e.toString()}');
    }
  }
}
