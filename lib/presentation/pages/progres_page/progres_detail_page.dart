import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_detail_provider.dart';

import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/progres_hafalan_widget/progres_hafalan_detail_card.dart';

class ProgresDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ProgresDetailPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ProgresDetailPage> createState() => _ProgresDetailPageState();
}

class _ProgresDetailPageState extends ConsumerState<ProgresDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(userDataProvider).valueOrNull;
      if (user != null) {
        ref
            .read(progresDetailNotifierProvider.notifier)
            .getLatestProgres(widget.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    final isAdmin = user?.role == 'admin' || user?.role == 'superAdmin';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Progres',
          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
      ),
      body: ref.watch(progresDetailNotifierProvider).when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(progresDetailNotifierProvider.notifier)
                          .getLatestProgres(widget.id);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
            data: (progres) => progres == null
                ? const Center(
                    child: Text('Data tidak ditemukan'),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ProgresHafalanDetailCard(
                          progres: progres,
                          isAdmin: isAdmin,
                          onEdit: isAdmin
                              ? () => context.pushNamed(
                                    'edit-progres',
                                    pathParameters: {'id': progres.id},
                                  )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildAdditionalInfo(progres),
                      ],
                    ),
                  ),
          ),
    );
  }

  Widget _buildAdditionalInfo(ProgresHafalan progres) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Info Tambahan',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            if (progres.createdBy != null) ...[
              Text(
                'Dibuat oleh: ${progres.createdBy}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            if (progres.createdAt != null) ...[
              Text(
                'Tanggal dibuat: ${formatDateTime(progres.createdAt!)}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            if (progres.updatedBy != null) ...[
              Text(
                'Terakhir diubah oleh: ${progres.updatedBy}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            if (progres.updatedAt != null) ...[
              Text(
                'Tanggal diubah: ${formatDateTime(progres.updatedAt!)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
