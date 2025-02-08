import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';
import 'package:sti_app/presentation/widgets/sti_text_field_widget.dart';

class ProgresHafalanFormCard extends StatelessWidget {
  final String programId;
  final String? juz;
  final String? halaman;
  final String? ayat;
  final String? surah;
  final String? statusPenilaian;
  final String? iqroLevel;
  final String? iqroHalaman;
  final String? statusIqro;
  final String? mutabaahTarget;
  final String? statusMutabaah;
  final String? catatan;
  final DateTime? selectedDate;
  final ValueChanged<String> onJuzChanged;
  final ValueChanged<String> onHalamanChanged;
  final ValueChanged<String> onAyatChanged;
  final ValueChanged<String> onSurahChanged;
  final ValueChanged<String> onStatusPenilaianChanged;
  final ValueChanged<String> onIqroLevelChanged;
  final ValueChanged<String> onIqroHalamanChanged;
  final ValueChanged<String> onStatusIqroChanged;
  final ValueChanged<String> onMutabaahTargetChanged;
  final ValueChanged<String> onStatusMutabaahChanged;
  final ValueChanged<String> onCatatanChanged;
  final ValueChanged<DateTime> onDateChanged;

  const ProgresHafalanFormCard({
    super.key,
    required this.programId,
    this.juz,
    this.halaman,
    this.ayat,
    this.surah,
    this.statusPenilaian,
    this.iqroLevel,
    this.iqroHalaman,
    this.statusIqro,
    this.mutabaahTarget,
    this.statusMutabaah,
    this.catatan,
    this.selectedDate,
    required this.onJuzChanged,
    required this.onHalamanChanged,
    required this.onAyatChanged,
    required this.onSurahChanged,
    required this.onStatusPenilaianChanged,
    required this.onIqroLevelChanged,
    required this.onIqroHalamanChanged,
    required this.onStatusIqroChanged,
    required this.onMutabaahTargetChanged,
    required this.onStatusMutabaahChanged,
    required this.onCatatanChanged,
    required this.onDateChanged,
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
            Text(
              programId == 'TAHFIDZ'
                  ? 'Form Progres Tahfidz'
                  : 'Form Progres GMM',
              style: AppTextStyles.h3,
            ),
            verticalSpace(16),

            // Date Picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
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
                      ? formatDate(selectedDate!)
                      : 'Pilih tanggal',
                ),
              ),
            ),
            verticalSpace(16),

            // Program specific fields
            if (programId == 'TAHFIDZ') ...[
              // Tahfidz Fields
              Row(
                children: [
                  Expanded(
                    child: STITextField(
                      labelText: 'Juz',
                      controller: TextEditingController(text: juz),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onJuzChanged,
                    ),
                  ),
                  horizontalSpace(8),
                  Expanded(
                    child: STITextField(
                      labelText: 'Halaman',
                      controller: TextEditingController(text: halaman),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onHalamanChanged,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),
              Row(
                children: [
                  Expanded(
                    child: STITextField(
                      labelText: 'Ayat',
                      controller: TextEditingController(text: ayat),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onAyatChanged,
                    ),
                  ),
                  horizontalSpace(8),
                  Expanded(
                    child: STITextField(
                      labelText: 'Surah',
                      controller: TextEditingController(text: surah),
                      onChanged: onSurahChanged,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),
              DropdownButtonFormField<String>(
                value: statusPenilaian,
                decoration: const InputDecoration(
                  labelText: 'Status Penilaian',
                  border: OutlineInputBorder(),
                ),
                items: ['Lancar', 'Belum', 'Perlu Perbaikan']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onStatusPenilaianChanged(value);
                },
              ),
            ] else ...[
              // GMM Fields
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: iqroLevel,
                      decoration: const InputDecoration(
                        labelText: 'Level Iqro',
                        border: OutlineInputBorder(),
                      ),
                      items: ['1', '2', '3', '4', '5', '6']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text('Level $level'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onIqroLevelChanged(value);
                      },
                    ),
                  ),
                  horizontalSpace(8),
                  Expanded(
                    child: STITextField(
                      labelText: 'Halaman',
                      controller: TextEditingController(text: iqroHalaman),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onIqroHalamanChanged,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),
              DropdownButtonFormField<String>(
                value: statusIqro,
                decoration: const InputDecoration(
                  labelText: 'Status Iqro',
                  border: OutlineInputBorder(),
                ),
                items: ['Lancar', 'Belum']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onStatusIqroChanged(value);
                },
              ),
              verticalSpace(16),
              STITextField(
                labelText: 'Target Mutabaah',
                controller: TextEditingController(text: mutabaahTarget),
                onChanged: onMutabaahTargetChanged,
              ),
              verticalSpace(16),
              DropdownButtonFormField<String>(
                value: statusMutabaah,
                decoration: const InputDecoration(
                  labelText: 'Status Mutabaah',
                  border: OutlineInputBorder(),
                ),
                items: ['Tercapai', 'Belum']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onStatusMutabaahChanged(value);
                },
              ),
            ],
            verticalSpace(16),

            // Common Fields
            STITextField(
              labelText: 'Catatan',
              controller: TextEditingController(text: catatan),
              maxLines: 3,
              onChanged: onCatatanChanged,
            ),
          ],
        ),
      ),
    );
  }
}
