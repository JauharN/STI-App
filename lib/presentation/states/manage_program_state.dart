import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/presensi/program_detail.dart';

part 'manage_program_state.freezed.dart';

@freezed
class ManageProgramState with _$ManageProgramState {
  const factory ManageProgramState.initial() = _Initial;
  const factory ManageProgramState.loading() = _Loading;
  const factory ManageProgramState.loaded(List<ProgramDetail> programList) =
      _Loaded;
  const factory ManageProgramState.error(String message) = _Error;
}
