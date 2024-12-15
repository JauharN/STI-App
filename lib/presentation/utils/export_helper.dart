import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/presensi/presensi_statistics_data.dart';
import '../../../domain/entities/presensi/santri_statistics.dart';
import '../../domain/entities/presensi/presensi_status.dart';

class ExportHelper {
  // Format tanggal untuk nama file
  static String _getFormattedDate() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  // Get temporary directory untuk menyimpan file
  static Future<String> _getExportPath(String filename) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/$filename';
  }

  // Export ke PDF
  static Future<File> exportToPDF({
    required String title,
    required PresensiStatisticsData stats,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Buat dokumen PDF
    final pdf = pw.Document();

    // Header
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(title),
              ),

              // Period
              if (startDate != null && endDate != null)
                pw.Text(
                  'Periode: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                ),

              pw.SizedBox(height: 20),

              // Overview Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Overview',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Pertemuan: ${stats.totalPertemuan}'),
                    pw.Text('Total Santri: ${stats.totalSantri}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Attendance Statistics
              _buildAttendanceStatistics(stats),

              pw.SizedBox(height: 20),

              // Santri Statistics Table
              _buildSantriStatisticsTable(stats.santriStats),
            ],
          );
        },
      ),
    );

    // Save file
    final filename = 'presensi_report_${_getFormattedDate()}.pdf';
    final path = await _getExportPath(filename);
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Export ke Excel
  static Future<File> exportToExcel({
    required PresensiStatisticsData stats,
    required String programName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final excel = Excel.createExcel();

    // Sheet Overview
    final overview = excel['Overview'];

    // Add title and period
    overview.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Laporan Presensi $programName')
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

    if (startDate != null && endDate != null) {
      overview
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
              .value =
          TextCellValue(
              'Periode: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}');
    }

    // Add headers
    final headers = [
      'Nama Santri',
      'Total Kehadiran',
      'Persentase',
      'Hadir',
      'Sakit',
      'Izin',
      'Alpha'
    ];
    for (var i = 0; i < headers.length; i++) {
      overview.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(bold: true);
    }

    // Add data
    var currentRow = 4;
    for (var santri in stats.santriStats) {
      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(santri.santriName);

      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = IntCellValue(santri.totalKehadiran);

      overview
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 2, rowIndex: currentRow))
              .value =
          TextCellValue('${santri.persentaseKehadiran.toStringAsFixed(1)}%');

      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = IntCellValue(santri.statusCount[PresensiStatus.hadir] ?? 0);

      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = IntCellValue(santri.statusCount[PresensiStatus.sakit] ?? 0);

      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = IntCellValue(santri.statusCount[PresensiStatus.izin] ?? 0);

      overview
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow))
          .value = IntCellValue(santri.statusCount[PresensiStatus.alpha] ?? 0);

      currentRow++;
    }

    // Auto-fit columns
    for (var i = 0; i < headers.length; i++) {
      overview.setColumnWidth(i, 15);
    }

    // Save file
    final filename = 'presensi_report_${_getFormattedDate()}.xlsx';
    final path = await _getExportPath(filename);
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  // Helper untuk membangun tabel statistik santri di PDF
  static pw.Widget _buildSantriStatisticsTable(List<SantriStatistics> stats) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header
        pw.TableRow(
          children: [
            pw.Text('Nama Santri'),
            pw.Text('Total Kehadiran'),
            pw.Text('Persentase'),
            pw.Text('H'),
            pw.Text('S'),
            pw.Text('I'),
            pw.Text('A'),
          ],
        ),
        // Data rows
        ...stats
            .map((santri) => pw.TableRow(
                  children: [
                    pw.Text(santri.santriName),
                    pw.Text(santri.totalKehadiran.toString()),
                    pw.Text(
                        '${santri.persentaseKehadiran.toStringAsFixed(1)}%'),
                    pw.Text(
                        santri.statusCount[PresensiStatus.hadir]?.toString() ??
                            '0'),
                    pw.Text(
                        santri.statusCount[PresensiStatus.sakit]?.toString() ??
                            '0'),
                    pw.Text(
                        santri.statusCount[PresensiStatus.izin]?.toString() ??
                            '0'),
                    pw.Text(
                        santri.statusCount[PresensiStatus.alpha]?.toString() ??
                            '0'),
                  ],
                ))
            .toList(),
      ],
    );
  }

  // Helper untuk membangun statistik kehadiran di PDF
  static pw.Widget _buildAttendanceStatistics(PresensiStatisticsData stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Statistik Kehadiran',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Hadir: ${stats.totalByStatus[PresensiStatus.hadir] ?? 0}'),
          pw.Text('Sakit: ${stats.totalByStatus[PresensiStatus.sakit] ?? 0}'),
          pw.Text('Izin: ${stats.totalByStatus[PresensiStatus.izin] ?? 0}'),
          pw.Text('Alpha: ${stats.totalByStatus[PresensiStatus.alpha] ?? 0}'),
        ],
      ),
    );
  }

  // Share file yang sudah di-export
  static Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Laporan Presensi',
    );
  }
}
