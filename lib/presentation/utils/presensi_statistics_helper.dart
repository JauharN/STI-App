import 'package:intl/intl.dart';
import 'package:sti_app/domain/entities/presensi/presensi_pertemuan.dart';
import 'package:sti_app/domain/entities/presensi/presensi_status.dart';
import 'package:sti_app/domain/entities/presensi/santri_statistics.dart';

class PresensiStatisticsHelper {
  // Menghitung trend kehadiran berdasarkan tanggal
  static Map<String, double> calculateTrendKehadiran(
      List<PresensiPertemuan> presensiList) {
    final Map<String, double> trend = {};

    for (var presensi in presensiList) {
      final date = DateFormat('yyyy-MM-dd').format(presensi.tanggal);
      if (presensi.summary.totalSantri > 0) {
        trend[date] =
            (presensi.summary.hadir / presensi.summary.totalSantri) * 100;
      } else {
        trend[date] = 0.0;
      }
    }
    return trend;
  }

  // Menghitung total status presensi
  static Map<PresensiStatus, int> calculateTotalByStatus(
      List<PresensiPertemuan> presensiList) {
    final Map<PresensiStatus, int> totalByStatus = {};

    for (var presensi in presensiList) {
      for (var santri in presensi.daftarHadir) {
        totalByStatus.update(
          santri.status,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    return totalByStatus;
  }

  // Menghitung statistik per santri
  static Future<List<SantriStatistics>> calculateSantriStatistics(
      List<PresensiPertemuan> presensiList) async {
    final Map<String, Map<String, dynamic>> santriStatsMap = {};

    // Initialize dan update statistik untuk setiap santri
    for (var presensi in presensiList) {
      for (var santri in presensi.daftarHadir) {
        if (!santriStatsMap.containsKey(santri.santriId)) {
          santriStatsMap[santri.santriId] = {
            'santriName': santri.santriName,
            'totalKehadiran': 0,
            'statusCount': <PresensiStatus, int>{},
          };
        }

        // Update status count
        final statusCount = santriStatsMap[santri.santriId]!['statusCount']
            as Map<PresensiStatus, int>;
        statusCount.update(
          santri.status,
          (value) => value + 1,
          ifAbsent: () => 1,
        );

        // Update total kehadiran
        if (santri.status == PresensiStatus.hadir) {
          santriStatsMap[santri.santriId]!['totalKehadiran'] =
              (santriStatsMap[santri.santriId]!['totalKehadiran'] as int) + 1;
        }
      }
    }

    // Convert ke list SantriStatistics
    return santriStatsMap.entries.map((entry) {
      final stats = entry.value;
      final totalKehadiran = stats['totalKehadiran'] as int;
      final persentase = presensiList.isEmpty
          ? 0.0
          : (totalKehadiran / presensiList.length) * 100;

      return SantriStatistics(
        santriId: entry.key,
        santriName: stats['santriName'],
        totalKehadiran: totalKehadiran,
        totalPertemuan: presensiList.length,
        statusCount: stats['statusCount'] as Map<PresensiStatus, int>,
        persentaseKehadiran: persentase,
      );
    }).toList();
  }
}
