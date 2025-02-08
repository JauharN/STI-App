import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sti_app/domain/entities/progres_hafalan.dart';
import 'package:sti_app/presentation/misc/constants.dart';
import 'package:sti_app/presentation/misc/methods.dart';
import 'package:sti_app/presentation/providers/progres_hafalan/progres_hafalan_provider.dart';

import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/progres_hafalan_widget/progres_hafalan_list_item.dart';

class ManageProgresPage extends ConsumerStatefulWidget {
  const ManageProgresPage({super.key});

  @override
  ConsumerState<ManageProgresPage> createState() => _ManageProgresPageState();
}

class _ManageProgresPageState extends ConsumerState<ManageProgresPage> {
  String? _selectedProgramId;
  DateTime? _startDate;
  DateTime? _endDate;

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
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Progres Hafalan',
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
          Expanded(
            child: ref.watch(progresHafalanNotifierProvider).when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(error.toString()),
                  ),
                  data: (progresList) {
                    // Apply filters
                    final filteredList = _filterProgresList(progresList);

                    if (filteredList.isEmpty) {
                      return _buildEmptyState();
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
                          onDelete: () => _onDeletePressed(progres, user.uid),
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('input-progres'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.neutral100),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
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
            onChanged: (value) {
              setState(() => _selectedProgramId = value);
            },
          ),
          const SizedBox(height: 16),
          // Date range filter
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Dari Tanggal',
                  value: _startDate,
                  onChanged: (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePicker(
                  label: 'Sampai Tanggal',
                  value: _endDate,
                  onChanged: (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
        );
        onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null ? formatDate(value) : 'Pilih tanggal',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  List<ProgresHafalan> _filterProgresList(List<ProgresHafalan> progresList) {
    return progresList.where((progres) {
      // Filter by program
      if (_selectedProgramId != null &&
          progres.programId != _selectedProgramId) {
        return false;
      }

      // Filter by date range
      if (_startDate != null && progres.tanggal.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          progres.tanggal.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
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

  Future<void> _onDeletePressed(ProgresHafalan progres, String userId) async {
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

    if (confirmed == true) {
      await ref
          .read(progresHafalanNotifierProvider.notifier)
          .deleteProgres(progres.id, userId);
    }
  }
}
