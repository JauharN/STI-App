import 'package:sti_app/data/repositories/sesi_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/sesi.dart';

class FirebaseSesiRepository implements SesiRepository {
  @override
  Future<Result<Sesi>> createSesi(Sesi sesi) {
    // TODO: implement createSesi
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteSesi(String sesiId) {
    // TODO: implement deleteSesi
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Sesi>>> getSesiByProgramId(String programId) {
    // TODO: implement getSesiByProgramId
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Sesi>>> getUpcomingSesi(String programId) {
    // TODO: implement getUpcomingSesi
    throw UnimplementedError();
  }

  @override
  Future<Result<Sesi>> updateSesi(Sesi sesi) {
    // TODO: implement updateSesi
    throw UnimplementedError();
  }
}
