import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/usecases/user_management/get_users_by_role_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management_widget/user_list_item_widget.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  // Controller untuk search
  final searchController = TextEditingController();

  // Filter state
  UserRole selectedRole = UserRole.santri;
  bool showInactive = false;
  String _searchQuery = '';

  // Handlers
  void _handleRoleFilter(UserRole role) {
    setState(() {
      selectedRole = role;
      // Reset search when changing filters
      searchController.clear();
    });
    // Could add analytics tracking here
  }

  void _handleInactiveFilter(bool? value) {
    setState(() {
      showInactive = value ?? false;
      // Reset search when changing filters
      searchController.clear();
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Handler for navigation
  void _navigateToUserDetail(String userId) {
    context.pushNamed(
      'user-detail',
      pathParameters: {'userId': userId},
    );
  }

  void _navigateToRoleManagement() {
    // Only allow superAdmin to access role management
    final currentUserRole = ref.read(userDataProvider).value?.role;
    if (currentUserRole == UserRole.superAdmin) {
      context.pushNamed('role-management');
    } else {
      context.showSnackBar('Only Super Admin can access role management');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      searchController.clear();
      selectedRole = UserRole.santri;
      showInactive = false;
    });
    // Invalidate cache to force refresh
    ref.invalidate(getUsersByRoleProvider);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // UI Components
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Management',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage all users in the system',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: STITextField(
        labelText: 'Search Users',
        controller: searchController,
        prefixIcon: const Icon(Icons.search),
        validator: (value) => null,
        // Tambahkan onChanged untuk search
        onChanged: _handleSearch,
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  _handleSearch(''); // Reset search
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Role filter
          SegmentedButton<UserRole>(
            selected: {selectedRole},
            onSelectionChanged: (Set<UserRole> selection) {
              _handleRoleFilter(selection.first);
            },
            segments: UserRole.values
                .map((role) => ButtonSegment(
                      value: role,
                      label: Text(role.displayName),
                    ))
                .toList(),
          ),
          const SizedBox(width: 8),
          // Status filter
          FilterChip(
            label: const Text('Show Inactive'),
            selected: showInactive,
            onSelected: _handleInactiveFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Consumer(
        builder: (context, ref, child) {
          final usersAsync = ref.watch(getUsersByRoleProvider(
            roleToGet: selectedRole,
            currentUserRole:
                ref.watch(userDataProvider).value?.role ?? UserRole.santri,
            includeInactive: showInactive,
          ));

          return usersAsync.when(
            loading: () => const LoadingState(),
            error: (error, stack) => ErrorState(
              message: error.toString(), // Pass specific error message
              onRetry: _handleRefresh, // Add retry functionality
            ),
            data: (users) {
              // Apply search filter
              final filteredUsers = users
                  .where((user) =>
                      user.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      user.email
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

              if (filteredUsers.isEmpty) {
                return const EmptyState();
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return UserListItemWidget(
                    user: user,
                    onTap: () => _navigateToUserDetail(user.uid),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: _navigateToRoleManagement,
          )
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
