import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../domain/entities/presensi/santri_detail.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../extensions/extensions.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/manage_santri_provider.dart';
import '../../../../providers/program/available_programs_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../widgets/presensi_widget/santri_form_dialog_widget.dart';

class ManageSantriConstants {
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int searchDebounceMs = 500;
}

class ManageSantriPage extends ConsumerStatefulWidget {
  const ManageSantriPage({super.key});

  @override
  ConsumerState<ManageSantriPage> createState() => _ManageSantriPageState();
}

class _ManageSantriPageState extends ConsumerState<ManageSantriPage> {
  String searchQuery = '';
  String filterProgram = 'all';
  String sortBy = 'name'; // name, program, status
  final searchController = TextEditingController();
  Timer? _searchDebounce;
  bool isProcessing = false;

  bool _canManageSantri(UserRole? userRole) {
    return userRole == UserRole.admin || userRole == UserRole.superAdmin;
  }

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = ManageSantriConstants.maxRetries,
    int timeoutSeconds = ManageSantriConstants.timeoutSeconds,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation().timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw TimeoutException('Operation timed out');
          },
        );
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
                'Operation failed after $maxRetries attempts: ${e.toString()}');
          }
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    // Initialize santri data
    _loadInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Refresh santri list
    await ref.read(manageSantriControllerProvider.notifier).build();
  }

  @override
  Widget build(BuildContext context) {
    final santriListAsync = ref.watch(manageSantriControllerProvider);
    final userRole = ref.watch(userDataProvider).value?.role;
    if (!_canManageSantri(userRole)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permission to manage santri',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Santri',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Search action
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                // Toggle search bar visibility
              });
            },
          ),
          // Filter action
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          // Sort action
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddSantriDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: santriListAsync.when(
              data: (state) => state.when(
                initial: () => _buildSantriList(),
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (santriList) =>
                    _buildSantriList(santriList: santriList),
                error: (message) => Center(child: Text(message)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSantriDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari santri berdasarkan nama atau email...',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral500,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.neutral500,
              ),
              filled: true,
              fillColor: AppColors.neutral100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.neutral300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.neutral300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        ref
                            .read(manageSantriControllerProvider.notifier)
                            .searchSantri('');
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.neutral500,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              // Debounce search
              Future.delayed(const Duration(milliseconds: 300), () {
                if (searchQuery == value) {
                  ref
                      .read(manageSantriControllerProvider.notifier)
                      .searchSantri(value);
                }
              });
            },
          ),

          // Advanced filter row
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter button
                TextButton.icon(
                  onPressed: () => _showFilterDialog(),
                  icon: const Icon(
                    Icons.filter_list,
                    size: 20,
                  ),
                  label: Text(
                    'Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neutral700,
                  ),
                ),

                // Sort button
                TextButton.icon(
                  onPressed: () => _showSortDialog(),
                  icon: const Icon(
                    Icons.sort,
                    size: 20,
                  ),
                  label: Text(
                    'Urutkan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),

          // Active filters chips (if any)
          if (filterProgram != 'all' || sortBy != 'name') ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (filterProgram != 'all')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Program: $filterProgram'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            filterProgram = 'all';
                          });
                          ref
                              .read(manageSantriControllerProvider.notifier)
                              .filterByProgram('all');
                        },
                      ),
                    ),
                  if (sortBy != 'name')
                    Chip(
                      label: Text('Urut: ${_getSortLabel(sortBy)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          sortBy = 'name';
                        });
                        // Implement sort logic
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

// Helper for searchbar
  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'name':
        return 'Nama';
      case 'program':
        return 'Program';
      case 'status':
        return 'Status';
      default:
        return 'Nama';
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Filter Program',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),
          // Program chips
          SizedBox(
            height: 40,
            child: ref.watch(availableProgramsProvider).when(
                  data: (programs) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // All Programs chip
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              'Semua',
                              style: GoogleFonts.plusJakartaSans(
                                color: filterProgram == 'all'
                                    ? Colors.white
                                    : AppColors.neutral700,
                              ),
                            ),
                            selected: filterProgram == 'all',
                            onSelected: (selected) {
                              setState(() {
                                filterProgram = 'all';
                              });
                              ref
                                  .read(manageSantriControllerProvider.notifier)
                                  .filterByProgram('all');
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: filterProgram == 'all'
                                  ? AppColors.primary
                                  : AppColors.neutral300,
                            ),
                          ),
                        ),
                        // Program specific chips
                        ...programs.map(
                          (program) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                program.nama,
                                style: GoogleFonts.plusJakartaSans(
                                  color: filterProgram == program.id
                                      ? Colors.white
                                      : AppColors.neutral700,
                                ),
                              ),
                              selected: filterProgram == program.id,
                              onSelected: (selected) {
                                setState(() {
                                  filterProgram = program.id;
                                });
                                ref
                                    .read(
                                        manageSantriControllerProvider.notifier)
                                    .filterByProgram(program.id);
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primary,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: filterProgram == program.id
                                    ? AppColors.primary
                                    : AppColors.neutral300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error: ${error.toString()}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
          ),

          // Active filters summary
          if (filterProgram != 'all') ...[
            const SizedBox(height: 8),
            Text(
              'Menampilkan santri dari program: ${_getProgramName(filterProgram)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.neutral600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

// Helper method untuk mendapatkan nama program
  String _getProgramName(String programId) {
    final programs = ref.read(availableProgramsProvider).valueOrNull ?? [];
    try {
      final program = programs.firstWhere((p) => p.id == programId);
      return program.nama;
    } catch (_) {
      return programId;
    }
  }

  Widget _buildSantriList({List<SantriDetail>? santriList}) {
    // Empty state
    if (santriList == null || santriList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.neutral400,
            ),
            verticalSpace(16),
            Text(
              'Belum ada data santri',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.neutral600,
              ),
            ),
            Text(
              'Tambahkan santri baru dengan menekan tombol +',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // List View with santri cards
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: santriList.length,
      itemBuilder: (context, index) {
        final santri = santriList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: santri.photoUrl != null
                  ? NetworkImage(santri.photoUrl!)
                  : null,
              child: santri.photoUrl == null
                  ? Text(
                      santri.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              santri.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  santri.email,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.neutral600,
                    fontSize: 12,
                  ),
                ),
                if (santri.enrolledPrograms.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: santri.enrolledPrograms.map((program) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          program,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await _showEditSantriDialog(santri.id);
                    break;
                  case 'delete':
                    await _showDeleteConfirmation(santri.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddSantriDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SantriFormDialog(),
    );

    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Santri berhasil ditambahkan');
        // Refresh list
        ref.refresh(manageSantriControllerProvider);
      }
    }
  }

  Future<void> _showEditSantriDialog(String santriId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SantriFormDialog(santriId: santriId),
    );

    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Data santri berhasil diperbarui');
        // Refresh list
        ref.refresh(manageSantriControllerProvider);
      }
    }
  }

  Future<void> _showDeleteConfirmation(String santriId) async {
    final santriList = ref.read(manageSantriControllerProvider).valueOrNull;
    final santri = santriList?.whenOrNull(
      loaded: (list) => list.firstWhereOrNull((s) => s.id == santriId),
    );

    if (santri == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Santri',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda yakin ingin menghapus santri:',
              style: GoogleFonts.plusJakartaSans(),
            ),
            const SizedBox(height: 8),
            Text(
              santri.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              santri.email,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => isProcessing = true);
      try {
        final success = await _handleOperationWithRetry(() async {
          final deleteResult = await ref
              .read(manageSantriControllerProvider.notifier)
              .deleteSantri(santriId);

          if (!deleteResult.isSuccess) {
            throw Exception(deleteResult.errorMessage);
          }
        });

        if (success && mounted) {
          context.showSuccessSnackBar('Santri berhasil dihapus');
          ref.refresh(manageSantriControllerProvider);
        }
      } finally {
        setState(() => isProcessing = false);
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Santri',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ref.watch(availableProgramsProvider).when(
                  data: (programs) => Column(
                    children: [
                      // All Programs
                      RadioListTile<String>(
                        title: const Text('Semua Program'),
                        value: 'all',
                        groupValue: filterProgram,
                        onChanged: (value) {
                          setState(() {
                            filterProgram = value!;
                          });
                          ref
                              .read(manageSantriControllerProvider.notifier)
                              .filterByProgram(value!);
                          Navigator.pop(context);
                        },
                      ),
                      // Program specific filters
                      ...programs.map(
                        (program) => RadioListTile<String>(
                          title: Text(program.nama),
                          value: program.id,
                          groupValue: filterProgram,
                          onChanged: (value) {
                            setState(() {
                              filterProgram = value!;
                            });
                            ref
                                .read(manageSantriControllerProvider.notifier)
                                .filterByProgram(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Urutkan Berdasarkan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(
                'Nama',
                style: GoogleFonts.plusJakartaSans(),
              ),
              value: 'name',
              groupValue: sortBy,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  sortBy = value!;
                });
                ref
                    .read(manageSantriControllerProvider.notifier)
                    .sortSantri(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(
                'Program',
                style: GoogleFonts.plusJakartaSans(),
              ),
              value: 'program',
              groupValue: sortBy,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  sortBy = value!;
                });
                ref
                    .read(manageSantriControllerProvider.notifier)
                    .sortSantri(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(
                'Status',
                style: GoogleFonts.plusJakartaSans(),
              ),
              value: 'status',
              groupValue: sortBy,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  sortBy = value!;
                });
                ref
                    .read(manageSantriControllerProvider.notifier)
                    .sortSantri(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
