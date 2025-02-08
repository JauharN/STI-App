import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_hafalan_provider.dart';

import '../../../providers/user/available_santri_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/progres_hafalan_widget/progres_hafalan_list_item.dart';

class SantriProgresListPage extends ConsumerStatefulWidget {
  const SantriProgresListPage({super.key});

  @override
  ConsumerState<SantriProgresListPage> createState() =>
      _SantriProgresListPageState();
}

class _SantriProgresListPageState extends ConsumerState<SantriProgresListPage> {
  String? _selectedSantriId;
  String? _selectedProgramId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progres Hafalan Santri',
          style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _selectedSantriId != null
              ? Expanded(child: _buildProgresList())
              : Expanded(
                  child: Center(
                    child: Text(
                      'Pilih santri untuk melihat progres',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: _selectedSantriId != null
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(
                'input-progres',
                queryParameters: {'santriId': _selectedSantriId},
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.neutral100),
            )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Santri selection
          ref.watch(availableSantriProvider).when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Error: $error',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                data: (santriList) => DropdownButtonFormField<String>(
                  value: _selectedSantriId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Santri',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Pilih Santri'),
                    ),
                    ...santriList.map((santri) => DropdownMenuItem(
                          value: santri.uid,
                          child: Text(santri.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSantriId = value;
                      // Reset program selection
                      _selectedProgramId = null;
                    });
                    if (value != null) {
                      ref
                          .read(progresHafalanNotifierProvider.notifier)
                          .getProgresHafalan(value);
                    }
                  },
                ),
              ),
          const SizedBox(height: 16),
          // Program filter
          DropdownButtonFormField<String>(
            value: _selectedProgramId,
            decoration: const InputDecoration(
              labelText: 'Filter Program',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Semua Program')),
              DropdownMenuItem(value: 'TAHFIDZ', child: Text('Tahfidz')),
              DropdownMenuItem(value: 'GMM', child: Text('GMM')),
            ],
            onChanged: _selectedSantriId != null
                ? (value) => setState(() => _selectedProgramId = value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProgresList() {
    return ref.watch(progresHafalanNotifierProvider).when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text(error.toString()),
          ),
          data: (progresList) {
            // Apply program filter
            final filteredList = _selectedProgramId != null
                ? progresList
                    .where((p) => p.programId == _selectedProgramId)
                    .toList()
                : progresList;

            if (filteredList.isEmpty) {
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
                    const SizedBox(height: 8),
                    Text(
                      'Tap + untuk menambah progres',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final progres = filteredList[index];
                return ProgresHafalanListItem(
                  progres: progres,
                  isAdmin: true,
                  onTap: () => _onItemTap(progres),
                  onEdit: () => _onEditPressed(progres),
                  onDelete: () => _onDeletePressed(progres),
                );
              },
            );
          },
        );
  }

  void _onItemTap(ProgresHafalan progres) {
    context.pushNamed(
      'progres-detail',
      pathParameters: {'id': progres.id},
    );
  }

  void _onEditPressed(ProgresHafalan progres) {
    context.pushNamed(
      'edit-progres',
      pathParameters: {'id': progres.id},
    );
  }

  Future<void> _onDeletePressed(ProgresHafalan progres) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Progres'),
        content: const Text('Anda yakin ingin menghapus progres ini?'),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => GoRouter.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedSantriId != null) {
      await ref
          .read(progresHafalanNotifierProvider.notifier)
          .deleteProgres(progres.id, _selectedSantriId!);
    }
  }
}
