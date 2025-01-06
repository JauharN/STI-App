import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';

part 'presensi_state.freezed.dart';

@freezed
class PresensiState with _$PresensiState {
  const factory PresensiState.initial() = _Initial;
  const factory PresensiState.loading() = _Loading;
  const factory PresensiState.loaded(List<PresensiPertemuan> presensiList) =
      _Loaded;
  const factory PresensiState.error(String message) = _Error;
}
