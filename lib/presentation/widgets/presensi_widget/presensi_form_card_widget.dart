import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/presentation/misc/methods.dart';

class PresensiFormCard extends StatelessWidget {
  final int pertemuanKe;
  final DateTime? selectedDate;
  final String? materi;
  final String? catatan;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onMateriChanged;
  final ValueChanged<String> onCatatanChanged;

  const PresensiFormCard({
    super.key,
    required this.pertemuanKe,
    this.selectedDate,
    this.materi,
    this.catatan,
    required this.onDateChanged,
    required this.onMateriChanged,
    required this.onCatatanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header pertemuan
            Text(
              'Pertemuan ke-$pertemuanKe',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(16),

            // Date picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2025),
                );
                if (date != null) onDateChanged(date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(selectedDate!)
                      : 'Pilih tanggal',
                ),
              ),
            ),
            verticalSpace(16),

            // Input materi
            TextField(
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                labelText: 'Materi Pertemuan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              controller: TextEditingController(text: materi),
              onChanged: onMateriChanged,
              maxLines: 3,
            ),
            // Untuk catatan juga
            TextField(
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                labelText: 'Catatan Tambahan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              controller: TextEditingController(text: catatan),
              onChanged: onCatatanChanged,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
