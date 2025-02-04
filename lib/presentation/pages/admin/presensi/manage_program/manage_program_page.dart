import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../../domain/entities/presensi/program_detail.dart';
import '../../../../misc/constants.dart';
import '../../../../misc/methods.dart';
import '../../../../providers/presensi/admin/manage_program_provider.dart';
import '../../../../providers/user_data/user_data_provider.dart';
import '../../../../states/manage_program_state.dart';
import '../../../../widgets/presensi_widget/program_form_dialog_widget.dart';

class ManageProgramPage extends ConsumerStatefulWidget {
  const ManageProgramPage({super.key});

  @override
  ConsumerState<ManageProgramPage> createState() => _ManageProgramPageState();
}

class _ManageProgramPageState extends ConsumerState<ManageProgramPage> {
  // Constants
  static const int maxRetries = 3;
  static const int timeoutSeconds = 30;
  static const int filterDebounceMs = 500;

  // State variables
  String searchQuery = '';
  String selectedFilter = '';
  String selectedSort = '';
  Timer? _filterDebounce;
  bool isLoading = false;

  // Controllers
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    _filterDebounce?.cancel();
    super.dispose();
  }

  // Access control helper
  bool _canManageProgram(String? userRole) {
    return userRole == 'admin' || userRole == 'superAdmin';
  }

  // Error handling with retry
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
                'Operation failed after $maxRetries attempts: ${e.toString()}');
          }
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }

  // UI Methods
  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    if (!_canManageProgram(userRole)) {
      return _buildUnauthorizedView();
    }

    final programAsync = ref.watch(manageProgramControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSearchAndFilters(),
                    _buildProgramList(programAsync),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

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

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Program Management',
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
          onPressed: () => ref.refresh(manageProgramControllerProvider),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program List',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(8),
          Text(
            'Manage all learning programs',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search programs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _handleSearch,
          ),
          verticalSpace(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Programs', 'all'),
                horizontalSpace(8),
                _buildFilterChip('With Teacher', 'has_teacher'),
                horizontalSpace(8),
                _buildSortChip('Newest', 'newest'),
                horizontalSpace(8),
                _buildSortChip('Oldest', 'oldest'),
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
      selected: selectedFilter == value,
      onSelected: (selected) => _handleFilter(selected ? value : ''),
    );
  }

  Widget _buildSortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedSort == value,
      onSelected: (selected) => _handleSort(selected ? value : ''),
    );
  }

  Widget _buildProgramList(AsyncValue<ManageProgramState> programAsync) {
    return programAsync.when(
      data: (state) => state.when(
        initial: () => const Center(child: Text('Loading data...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (programList) {
          if (programList.isEmpty) {
            return _buildEmptyState();
          }
          return _buildProgramGrid(programList);
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              verticalSpace(16),
              Text(
                'Error: $message',
                style: GoogleFonts.plusJakartaSans(color: AppColors.error),
              ),
              verticalSpace(16),
              ElevatedButton(
                onPressed: () => ref.refresh(manageProgramControllerProvider),
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
  }

  Widget _buildProgramGrid(List<ProgramDetail> programs) {
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
      itemCount: programs.length,
      itemBuilder: (context, index) => _buildProgramCard(programs[index]),
    );
  }

  Widget _buildProgramCard(ProgramDetail program) {
    return Card(
      child: InkWell(
        onTap: () => _showProgramActions(program),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              verticalSpace(8),
              Text(
                program.description,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              verticalSpace(16),
              _buildProgramInfo(program),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramInfo(ProgramDetail program) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            Icons.people, '${program.enrolledSantriIds.length} Santri'),
        _buildInfoRow(Icons.person, program.teacherName ?? 'No Teacher'),
        _buildInfoRow(
            Icons.calendar_today, '${program.totalMeetings} Meetings'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neutral600),
          horizontalSpace(8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutral600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          verticalSpace(16),
          Text(
            'No programs yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            'Create your first program',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _showAddProgramDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
    );
  }

  // Action Methods
  void _handleSearch(String query) {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(
      const Duration(milliseconds: filterDebounceMs),
      () {
        setState(() => searchQuery = query.trim());
        ref
            .read(manageProgramControllerProvider.notifier)
            .searchPrograms(query);
      },
    );
  }

  void _handleFilter(String filter) {
    setState(() => selectedFilter = filter);
    ref.read(manageProgramControllerProvider.notifier).filterPrograms(filter);
  }

  void _handleSort(String sort) {
    setState(() => selectedSort = sort);
    ref.read(manageProgramControllerProvider.notifier).sortPrograms(sort);
  }

  Future<void> _showAddProgramDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProgramFormDialog(),
    );
    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Program successfully added');
        ref.refresh(manageProgramControllerProvider);
      }
    }
  }

  void _showProgramActions(ProgramDetail program) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Program'),
            onTap: () {
              Navigator.pop(context);
              _showEditProgramDialog(program.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: const Text(
              'Delete Program',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(program.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProgramDialog(String programId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgramFormDialog(programId: programId),
    );
    if (result == true) {
      if (mounted) {
        context.showSuccessSnackBar('Program successfully updated');
        ref.refresh(manageProgramControllerProvider);
      }
    }
  }

  Future<void> _showDeleteConfirmation(String programId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Program',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this program? This action cannot be undone.',
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
      setState(() => isLoading = true);

      try {
        final success = await _handleOperationWithRetry(() async {
          await ref
              .read(manageProgramControllerProvider.notifier)
              .deleteProgram(programId);
        });

        if (success && mounted) {
          context.showSuccessSnackBar('Program successfully deleted');
          ref.refresh(manageProgramControllerProvider);
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }
}
