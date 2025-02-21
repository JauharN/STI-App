import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) {
        final dateTime = value.toDate();

        // Validasi dasar - tidak boleh tahun yang tidak masuk akal
        if (dateTime.year < 2000 || dateTime.year > 2100) {
          throw ArgumentError('Invalid year: ${dateTime.year}');
        }

        return dateTime;
      }

      if (value is String) {
        final dateTime = DateTime.parse(value);

        // Validasi tanggal dari string
        if (dateTime.year < 2000 || dateTime.year > 2100) {
          throw ArgumentError('Invalid year from string: ${dateTime.year}');
        }

        return dateTime;
      }

      throw ArgumentError('Unsupported timestamp type: ${value.runtimeType}');
    } catch (e) {
      print('Error converting timestamp: $e');
      return null; // Return null on conversion error instead of throwing
    }
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;

    try {
      // Validasi tanggal sebelum konversi
      if (date.year < 2000 || date.year > 2100) {
        throw ArgumentError('Invalid year for conversion: ${date.year}');
      }

      return Timestamp.fromDate(date);
    } catch (e) {
      print('Error converting DateTime to Timestamp: $e');
      return null;
    }
  }

  /// Helper method untuk validasi timestamp
  static bool isValidTimestamp(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    final minDate = DateTime(2000);
    final maxDate = DateTime(2100);

    return date.isAfter(minDate) &&
        date.isBefore(maxDate) &&
        !date.isAfter(now.add(const Duration(days: 1))); // Allow 1 day buffer
  }

  /// Helper untuk format yang konsisten
  static DateTime? standardizeDateTime(DateTime? date) {
    if (date == null) return null;

    // Standardize to UTC and remove microseconds for consistency
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
  }
}
