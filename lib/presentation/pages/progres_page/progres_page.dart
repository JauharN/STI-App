import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_hafalan_provider.dart';
import 'package:sti_app/presentation/widgets/custom_app_bar_widget.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_data/user_data_provider.dart';
import '../../widgets/progres_hafalan_widget/progres_hafalan_list_item.dart';

class ProgresPage extends ConsumerStatefulWidget {
  const ProgresPage({super.key});

  @override
  ConsumerState<ProgresPage> createState() => _ProgresPageState();
}

class _ProgresPageState extends ConsumerState<ProgresPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(userDataProvider).valueOrNull;
      if (user != null) {
        ref
            .read(progresHafalanNotifierProvider.notifier)
            .getProgresHafalan(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    final isAdmin = user?.role == 'admin' || user?.role == 'superAdmin';

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(selectedPage: 2),
      ),
      body: ref.watch(progresHafalanNotifierProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (progresList) => progresList.isEmpty
                ? _buildEmptyState(isAdmin)
                : _buildProgresList(progresList, isAdmin, user),
          ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                context.pushNamed('input-progres');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.neutral100),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada progres hafalan',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Text(
              'Tap + untuk menambah progres',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgresList(
      List<ProgresHafalan> progresList, bool isAdmin, final user) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: progresList.length,
      itemBuilder: (context, index) {
        final progres = progresList[index];
        return ProgresHafalanListItem(
          progres: progres,
          isAdmin: isAdmin,
          onTap: () {
            context.pushNamed(
              'progres-detail',
              pathParameters: {'id': progres.id},
            );
          },
          onEdit: isAdmin
              ? () {
                  context.pushNamed(
                    'edit-progres',
                    pathParameters: {'id': progres.id},
                  );
                }
              : null,
          onDelete: isAdmin
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Progres'),
                      content:
                          const Text('Anda yakin ingin menghapus progres ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && user != null) {
                    await ref
                        .read(progresHafalanNotifierProvider.notifier)
                        .deleteProgres(progres.id, user.uid);
                  }
                }
              : null,
        );
      },
    );
  }
}
