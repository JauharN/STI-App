import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../../domain/entities/presensi/santri_detail.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/manage_santri_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../widgets/presensi_widget/santri_form_dialog_widget.dart';
import '../../../../widgets/sti_text_field_widget.dart';

class ManageSantriPage extends ConsumerStatefulWidget {
  const ManageSantriPage({super.key});

  @override
  ConsumerState<ManageSantriPage> createState() => _ManageSantriPageState();
}

class _ManageSantriPageState extends ConsumerState<ManageSantriPage> {
  // Constants
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int filterDebounceMs = 500;

  // Controllers
  final searchController = TextEditingController();

  // State variables
  String searchQuery = '';
  String filterProgram = 'all';
  String sortBy = 'name';
  Timer? _searchDebounce;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // RBAC Helper
  bool _canManageSantri(String? userRole) {
    return userRole == RoleConstants.admin ||
        userRole == RoleConstants.superAdmin;
  }

  // Data Loading
  Future<void> _loadInitialData() async {
    await ref.read(manageSantriControllerProvider.notifier).build();
  }

  // Error Handling Pattern
  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = maxRetries,
    int timeoutSeconds = timeoutSeconds,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await operation().timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () => throw TimeoutException('Operation timed out'),
        );
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          if (mounted) {
            context.showErrorSnackBar(
              'Operation failed after $maxRetries attempts: ${e.toString()}',
            );
          }
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  // Main Build
  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    if (!_canManageSantri(userRole)) {
      return _buildUnauthorizedView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMainContent(),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  // Unauthorized View
  Widget _buildUnauthorizedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
            verticalSpace(16),
            Text(
              'Access Denied',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpace(8),
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

  // Main Content
  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildSantriList(),
            ],
          ),
        ),
      ],
    );
  }

  // App Bar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Santri Management',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => ref.refresh(manageSantriControllerProvider),
        ),
      ],
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Santri',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Add, edit, or remove santri from programs',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          STITextField(
            labelText: 'Search santri',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: _handleSearch,
          ),
        ],
      ),
    );
  }

  // Filter Chips
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Program',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral600,
            ),
          ),
          verticalSpace(8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                horizontalSpace(8),
                _buildFilterChip('TAHFIDZ', 'TAHFIDZ'),
                horizontalSpace(8),
                _buildFilterChip('GMM', 'GMM'),
                horizontalSpace(8),
                _buildFilterChip('IFIS', 'IFIS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: filterProgram == value,
      onSelected: (selected) {
        setState(() => filterProgram = selected ? value : 'all');
        ref
            .read(manageSantriControllerProvider.notifier)
            .filterByProgram(filterProgram);
      },
    );
  }

  // Santri List
  Widget _buildSantriList() {
    return Consumer(
      builder: (context, ref, child) {
        final santriState = ref.watch(manageSantriControllerProvider);

        return santriState.when(
          data: (state) => state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (santriList) {
              if (santriList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildSantriGrid(santriList);
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  verticalSpace(16),
                  Text(
                    'Error: $message',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.error),
                  ),
                  verticalSpace(16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.refresh(manageSantriControllerProvider),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        );
      },
    );
  }

  Widget _buildSantriGrid(List<SantriDetail> santriList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: santriList.length,
      itemBuilder: (context, index) => _buildSantriCard(santriList[index]),
    );
  }

  Widget _buildSantriCard(SantriDetail santri) {
    return Card(
      child: InkWell(
        onTap: () => _showSantriActions(santri),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: santri.photoUrl != null
                      ? NetworkImage(santri.photoUrl!)
                      : const AssetImage('assets/profile-placeholder.png')
                          as ImageProvider,
                ),
              ),
              verticalSpace(16),
              // Name
              Text(
                santri.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Email
              Text(
                santri.email,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.neutral600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              verticalSpace(8),
              // Programs
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: santri.enrolledPrograms.map((program) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
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
            Icons.person_outline,
            size: 64,
            color: AppColors.neutral400,
          ),
          verticalSpace(16),
          Text(
            'No santri found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            'Add your first santri',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  Future<void> _handleSearch(String query) async {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: filterDebounceMs),
      () {
        setState(() => searchQuery = query.trim());
        ref.read(manageSantriControllerProvider.notifier).searchSantri(query);
      },
    );
  }

  void _showSantriActions(SantriDetail santri) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Santri'),
            onTap: () {
              Navigator.pop(context);
              _showEditSantriDialog(santri.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: const Text(
              'Delete Santri',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(santri.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _showAddSantriDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
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
        context.showSuccessSnackBar('Santri successfully added');
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
        context.showSuccessSnackBar('Santri successfully updated');
        ref.refresh(manageSantriControllerProvider);
      }
    }
  }

  Future<void> _showDeleteConfirmation(String santriId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Santri',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this santri? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isProcessing = true);

      try {
        final success = await _handleOperationWithRetry(() async {
          await ref
              .read(manageSantriControllerProvider.notifier)
              .deleteSantri(santriId);
        });

        if (success && mounted) {
          context.showSuccessSnackBar('Santri successfully deleted');
          ref.refresh(manageSantriControllerProvider);
        }
      } finally {
        if (mounted) {
          setState(() => isProcessing = false);
        }
      }
    }
  }
}
