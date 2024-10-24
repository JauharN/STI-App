import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/presensi_repository.dart';
import 'package:sti_app/domain/usecase/presensi/get_presensi_by_user/get_presensi_by_user_params.dart';
import '../../../entities/result.dart';
import '../../../entities/presensi.dart';

class GetPresensiByUser
    implements Usecase<Result<List<Presensi>>, GetPresensiByUserParams> {
  final PresensiRepository _presensiRepository;

  GetPresensiByUser({required PresensiRepository presensiRepository})
      : _presensiRepository = presensiRepository;

  @override
  Future<Result<List<Presensi>>> call(GetPresensiByUserParams params) async {
    if (params.userId.isEmpty) {
      return const Result.failed('Invalid user ID');
    }

    return _presensiRepository.getPresensiByUserId(params.userId);
  }
}
