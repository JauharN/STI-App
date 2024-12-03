import 'package:flutter/material.dart';

import '../../../domain/entities/user.dart';

class SantriPresensiCard extends StatelessWidget {
  final User santri; // Data santri
  final String? currentStatus; // Status yang sedang dipilih
  final String? keterangan; // Keterangan tambahan
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onKeteranganChanged;

  const SantriPresensiCard({
    super.key,
    required this.santri,
    this.currentStatus,
    this.keterangan,
    required this.onStatusChanged,
    required this.onKeteranganChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info santri dengan foto profile
            Row(
              children: [
                // Foto profile
                CircleAvatar(
                  backgroundImage: NetworkImage(santri.photoUrl ?? ''),
                  radius: 24,
                ),
                const SizedBox(width: 12),

                // Nama santri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        santri.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(santri.email),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown status kehadiran
            DropdownButtonFormField<String>(
              value: currentStatus,
              decoration: const InputDecoration(
                labelText: 'Status Kehadiran',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'HADIR', child: Text('Hadir')),
                DropdownMenuItem(value: 'SAKIT', child: Text('Sakit')),
                DropdownMenuItem(value: 'IZIN', child: Text('Izin')),
                DropdownMenuItem(value: 'ALPHA', child: Text('Alpha')),
              ],
              onChanged: (value) {
                if (value != null) onStatusChanged(value);
              },
            ),
            const SizedBox(height: 12),

            // Input keterangan
            TextField(
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: keterangan),
              onChanged: onKeteranganChanged,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
