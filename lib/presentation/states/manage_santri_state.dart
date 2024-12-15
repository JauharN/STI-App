import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/presensi/santri_detail.dart';

part 'manage_santri_state.freezed.dart';

@freezed
class ManageSantriState with _$ManageSantriState {
  const factory ManageSantriState.initial() = _Initial;
  const factory ManageSantriState.loading() = _Loading;
  const factory ManageSantriState.loaded(List<SantriDetail> santriList) =
      _Loaded;
  const factory ManageSantriState.error(String message) = _Error;
}
