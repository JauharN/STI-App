import 'package:flutter/material.dart';

import '../../domain/entities/presensi/presensi_status.dart';
import '../misc/constants.dart';

extension BuildContextExtension on BuildContext {
  // SnackBar dengan variasi
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Theme dan MediaQuery shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  // Navigation shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // Dialog helpers
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText ?? 'Ya',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showLoadingDialog() async {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// String Extensions
extension StringExtension on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get toTitleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

// DateTime Extensions
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  DateTime get dateOnly {
    return DateTime(year, month, day);
  }
}

extension PresensiStatusPresentation on PresensiStatus {
  Color get statusColor {
    switch (this) {
      case PresensiStatus.hadir:
        return AppColors.success;
      case PresensiStatus.sakit:
        return AppColors.warning;
      case PresensiStatus.izin:
        return Colors.blue;
      case PresensiStatus.alpha:
        return AppColors.error;
    }
  }
}

extension UserRoleExtension on String {
  bool get isSuperAdmin => this == 'superAdmin';
  bool get isAdmin => this == 'admin';
  bool get isSantri => this == 'santri';

  // Helper untuk role-based logic
  bool canManageUsers() => isSuperAdmin;
  bool canManageRoles() => isSuperAdmin;
  bool canManagePresensi() => isSuperAdmin || isAdmin;
  bool canViewPresensi() => true; // All roles can view

  // Get display name
  String get roleDisplayName {
    switch (this) {
      case 'superAdmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case 'santri':
        return 'Santri';
      default:
        return 'Unknown Role';
    }
  }
}
