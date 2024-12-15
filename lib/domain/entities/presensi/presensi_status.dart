import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum PresensiStatus {
  hadir,
  sakit,
  izin,
  alpha,
}

extension PresensiStatusX on PresensiStatus {
  String get label {
    switch (this) {
      case PresensiStatus.hadir:
        return 'Hadir';
      case PresensiStatus.sakit:
        return 'Sakit';
      case PresensiStatus.izin:
        return 'Izin';
      case PresensiStatus.alpha:
        return 'Alpha';
    }
  }

  String toJson() => name;

  static PresensiStatus fromJson(String json) {
    return PresensiStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => PresensiStatus.alpha,
    );
  }
}
