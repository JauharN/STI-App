import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

// Cache untuk SizedBox
Map<double, SizedBox> _verticalSpaces = {};
Map<double, SizedBox> _horizontalSpaces = {};

// Simplified SizedBox vertical
SizedBox verticalSpace(double height) {
  if (!_verticalSpaces.containsKey(height)) {
    _verticalSpaces[height] = SizedBox(height: height);
  }
  return _verticalSpaces[height]!;
}

// Simplified SizedBox horizontal
SizedBox horizontalSpace(double width) {
  if (!_horizontalSpaces.containsKey(width)) {
    _horizontalSpaces[width] = SizedBox(width: width);
  }
  return _horizontalSpaces[width]!;
}

// Format tanggal untuk tampilan
String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}

// Format waktu untuk tampilan
String formatTime(DateTime time) {
  return DateFormat('HH:mm', 'id_ID').format(time);
}

// Format tanggal dan waktu lengkap
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
}

// Helper untuk status presensi
Color getPresensiStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'HADIR':
      return Colors.green;
    case 'IZIN':
      return Colors.orange;
    case 'SAKIT':
      return Colors.blue;
    case 'ALPHA':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Helper untuk validasi
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool hasPermission(String userRole, String permission) {
  return RoleConstants.roleCapabilities[userRole]?.contains(permission) ??
      false;
}

bool canAccessPage(String userRole, String page) {
  switch (page) {
    case 'user_management':
      return userRole == RoleConstants.superAdmin;
    case 'role_management':
      return userRole == RoleConstants.superAdmin;
    case 'presensi_management':
      return userRole == RoleConstants.superAdmin ||
          userRole == RoleConstants.admin;
    case 'presensi_view':
      return true; // All roles
    default:
      return false;
  }
}

// untuk build runner
// dart run build_runner watch -d
