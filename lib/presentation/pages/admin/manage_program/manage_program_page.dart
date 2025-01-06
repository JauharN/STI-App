import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/presensi/admin/manage_program_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/presensi_widget/program_form_dialog.dart';

class ManageProgramConstants {
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int searchDebounceMs = 500;
}

class ManageProgramPage extends ConsumerStatefulWidget {
  const ManageProgramPage({super.key});
  @override
  ConsumerState<ManageProgramPage> createState() => _ManageProgramPageState();
}

class _ManageProgramPageState extends ConsumerState<ManageProgramPage> {
  // State variables
  String searchQuery = '';
  bool isLoading = false;
  String selectedFilter = '';
  String selectedSort = '';
  Timer? _searchDebounce;

  bool _canManageProgram(UserRole? userRole) {
    return userRole == UserRole.admin || userRole == UserRole.superAdmin;
  }

  // Controllers
  final searchController = TextEditingController();

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = ManageProgramConstants.maxRetries,
    int timeoutSeconds = ManageProgramConstants.timeoutSeconds,
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
  void dispose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;
    if (!_canManageProgram(userRole)) {
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
                'You don\'t have permission to manage programs',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final programAsync = ref.watch(manageProgramControllerProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterSection(),
              SizedBox(
                // Tambah ini
                height: MediaQuery.of(context).size.height - 200,
                child: _buildProgramList(programAsync),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  // UI Building Methods
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Manajemen Program',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.refresh(manageProgramControllerProvider),
        ),
      ],
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
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Cari program...',
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.neutral500),
                  onPressed: () {
                    searchController.clear();
                    _handleSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.neutral100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (searchQuery == value) {
              _handleSearch(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Urutan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Clear filter button
              if (searchQuery.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() => searchQuery = '');
                    ref.refresh(manageProgramControllerProvider);
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filter by status
                FilterChip(
                  label: const Text('Aktif'),
                  selected: false, // Connect to state
                  onSelected: (selected) {
                    _handleFilter('active');
                  },
                ),
                const SizedBox(width: 8),
                // Filter by teacher
                FilterChip(
                  label: const Text('Ada Pengajar'),
                  selected: selectedFilter == 'has_teacher', // Update ini
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter =
                          selected ? 'has_teacher' : ''; // Tambah ini
                    });
                    _handleFilter('has_teacher');
                  },
                ),
                const SizedBox(width: 8),
                // Sort options
                ChoiceChip(
                  label: const Text('Terbaru'),
                  selected: false, // Connect to state
                  onSelected: (selected) {
                    _handleSort('newest');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Terlama'),
                  selected: false, // Connect to state
                  onSelected: (selected) {
                    _handleSort('oldest');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramList(AsyncValue programAsync) {
    return programAsync.when(
      data: (state) => state.when(
        initial: () => const Center(child: Text('Memuat data...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (programList) {
          if (programList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada program',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: programList.length,
            itemBuilder: (context, index) {
              final program = programList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    program.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(program.deskripsi),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: program.jadwal.map((hari) {
                          return Chip(
                            label: Text(
                              hari,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                            ),
                          );
                        }).toList(),
                      ),
                      if (program.pengajarName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: AppColors.neutral600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pengajar: ${program.pengajarName}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditProgramDialog(program.id);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(program.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error),
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
        },
        error: (message) => Center(child: Text('Error: $message')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _showAddProgramDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
    );
  }

  // Dialog Methods
  Future<void> _showAddProgramDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProgramFormDialog(),
    );

    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Program berhasil ditambahkan');
        ref.refresh(manageProgramControllerProvider);
      }
    }
  }

  Future<void> _showEditProgramDialog(String programId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgramFormDialog(programId: programId),
    );

    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Program berhasil diperbarui');
        ref.refresh(manageProgramControllerProvider);
      }
    }
  }

  Future<void> _showDeleteConfirmation(String programId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Program',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yakin ingin menghapus program ini?'),
            const SizedBox(height: 8),
            Text('Program dengan ID: $programId'),
            const Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        final success = await _handleOperationWithRetry(() async {
          await ref
              .read(manageProgramControllerProvider.notifier)
              .deleteProgram(programId);
        });

        if (success && mounted) {
          context.showSuccessSnackBar('Program berhasil dihapus');
          ref.refresh(manageProgramControllerProvider);
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // Action Handler Methods
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      ref.refresh(manageProgramControllerProvider);
      return;
    }

    try {
      await ref
          .read(manageProgramControllerProvider.notifier)
          .searchPrograms(query);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan pencarian: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSort(String sortType) async {
    try {
      await ref
          .read(manageProgramControllerProvider.notifier)
          .sortPrograms(sortType);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengurutkan data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFilter(String filterType) async {
    try {
      await ref
          .read(manageProgramControllerProvider.notifier)
          .filterPrograms(filterType);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menerapkan filter: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    ref.refresh(manageProgramControllerProvider);
  }
}
