import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum PresensiStatus {
  hadir,
  sakit,
  izin,
  alpha;

  // Helper method untuk konversi ke string yang readable
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

  // Helper untuk serialization
  String toJson() => name;

  // Helper untuk deserialization dengan error handling
  static PresensiStatus fromJson(String json) {
    try {
      return PresensiStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == json.toLowerCase(),
        orElse: () => PresensiStatus.alpha,
      );
    } catch (e) {
      return PresensiStatus.alpha;
    }
  }

  // Helper untuk validasi
  static bool isValid(String status) {
    return PresensiStatus.values
        .map((e) => e.name.toLowerCase())
        .contains(status.toLowerCase());
  }

  // Helper untuk analytics
  static bool isHadirOrValid(PresensiStatus status) {
    return status == PresensiStatus.hadir ||
        status == PresensiStatus.sakit ||
        status == PresensiStatus.izin;
  }
}
