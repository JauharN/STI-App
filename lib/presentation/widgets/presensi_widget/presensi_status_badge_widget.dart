// presentation/widgets/presensi/presensi_status_badge.dart
import 'package:flutter/material.dart';

import '../../misc/constants.dart';

class PresensiStatusBadge extends StatelessWidget {
  final String status;

  const PresensiStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan status
    final color = switch (status) {
      'HADIR' => AppColors.success,
      'SAKIT' => AppColors.warning,
      'IZIN' => Colors.purple,
      'ALPHA' => AppColors.error,
      _ => AppColors.neutral300,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
