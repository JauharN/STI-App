import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'rate_limit_exception.dart';

/// Helper class untuk mengelola rate limiting pada login attempts
class RateLimitHelper {
  // Konstanta untuk rate limiting
  static const int maxAttempts = 5; // Maksimum percobaan login
  static const Duration limitDuration =
      Duration(minutes: 30); // Durasi pembatasan
  static const String _storageKey =
      'rate_limit_data'; // Key untuk SharedPreferences

  // Private fields
  final int _maxAttempts;
  final Duration _limitDuration;
  int _attempts = 0;
  DateTime? _firstAttemptTime;

  // Constructor dengan optional parameters
  RateLimitHelper({
    int? maxAttempts,
    Duration? limitDuration,
  })  : _maxAttempts = maxAttempts ?? RateLimitHelper.maxAttempts,
        _limitDuration = limitDuration ?? RateLimitHelper.limitDuration {
    _loadStoredData(); // Load data saat inisialisasi
  }

  /// Check apakah user sedang dalam pembatasan
  bool get isLimited {
    if (_firstAttemptTime == null) return false;

    if (DateTime.now().difference(_firstAttemptTime!) > _limitDuration) {
      reset();
      return false;
    }

    if (_attempts >= _maxAttempts) {
      final remaining = remainingLimitTime;
      throw RateLimitException(
          'Too many login attempts. Please try again in ${remaining?.inMinutes} minutes.');
    }

    return false;
  }

  /// Menambah jumlah percobaan login
  Future<void> incrementAttempt() async {
    _firstAttemptTime ??= DateTime.now();
    _attempts++;
    await _saveData(); // Simpan data setiap penambahan attempt
  }

  /// Reset semua data rate limiting
  Future<void> reset() async {
    _attempts = 0;
    _firstAttemptTime = null;
    await _clearData();
  }

  /// Mendapatkan sisa waktu pembatasan
  Duration? get remainingLimitTime {
    if (_firstAttemptTime == null || !isLimited) return null;

    final endTime = _firstAttemptTime!.add(_limitDuration);
    final remaining = endTime.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }

  /// Load data dari SharedPreferences
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);

      if (storedData != null) {
        final data = json.decode(storedData) as Map<String, dynamic>;
        _attempts = data['attempts'] as int;
        _firstAttemptTime = DateTime.parse(data['firstAttemptTime'] as String);
      }
    } catch (e) {
      print('Error loading rate limit data: $e');
      await reset(); // Reset jika terjadi error
    }
  }

  /// Simpan data ke SharedPreferences
  Future<void> _saveData() async {
    try {
      if (_firstAttemptTime == null) {
        await _clearData();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final data = {
        'attempts': _attempts,
        'firstAttemptTime': _firstAttemptTime!.toIso8601String(),
      };

      await prefs.setString(_storageKey, json.encode(data));
    } catch (e) {
      print('Error saving rate limit data: $e');
    }
  }

  /// Hapus data dari SharedPreferences
  Future<void> _clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing rate limit data: $e');
    }
  }

  // Getter untuk testing dan debugging
  int get attempts => _attempts;
  DateTime? get firstAttemptTime => _firstAttemptTime;
}
