import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../domain/entities/presensi/presensi_status.dart';
import '../../providers/presensi/admin/input_presensi_provider.dart';

class BulkActionBottomSheet extends ConsumerWidget {
  final String programId;
  final List<String> santriIds;
  final int pertemuanKe;
  final Function(String status, String keterangan) onStatusUpdate;

  const BulkActionBottomSheet({
    super.key,
    required this.programId,
    required this.santriIds,
    required this.pertemuanKe,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keteranganController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Update Presensi Massal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text('${santriIds.length} santri dipilih'),
          const SizedBox(height: 16),
          Row(
            children: PresensiStatus.values.map((status) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await _showKeteranganDialog(
                        context,
                        status,
                        keteranganController,
                      );
                      if (result == true) {
                        await ref
                            .read(inputPresensiControllerProvider.notifier)
                            .bulkUpdatePresensi(
                              programId: programId,
                              santriIds: santriIds,
                              status: status,
                              keterangan: keteranganController.text,
                              pertemuanKe: pertemuanKe,
                            );
                        if (context.mounted) {
                          onStatusUpdate(status.name.toUpperCase(),
                              keteranganController.text);
                          context.showSuccessSnackBar(
                              'Berhasil update ${santriIds.length} santri');
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(status.label),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showKeteranganDialog(
    BuildContext context,
    PresensiStatus status,
    TextEditingController controller,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keterangan ${status.label}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Optional...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
