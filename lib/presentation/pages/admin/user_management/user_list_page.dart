import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../misc/methods.dart';
import '../../../providers/usecases/user_management/get_users_by_role_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../states/empty_state.dart';
import '../../../states/error_state.dart';
import '../../../states/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management_widget/role_badge_widget.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  // Controllers
  final searchController = TextEditingController();

  // State variables
  String searchQuery = '';
  bool showInactive = false;
  bool isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Access control helper
  bool _hasAccess(String? userRole) {
    return userRole == RoleConstants.superAdmin ||
        userRole == RoleConstants.admin;
  }

  // Action Handlers
  void _handleSearch(String query) {
    setState(() => searchQuery = query.trim());
  }

  void _handleToggleInactive(bool? value) {
    setState(() => showInactive = value ?? false);
  }

  void _navigateToUserDetail(String userId) {
    context.pushNamed(
      'user-detail',
      pathParameters: {'userId': userId},
      extra: {'fromUserList': true},
    );
  }

  Future<void> _handleRefresh() async {
    final userRole = ref.read(userDataProvider).value?.role;
    ref.refresh(getUsersByRoleProvider(
      roleToGet: RoleConstants.santri,
      currentUserRole: userRole ?? RoleConstants.santri,
      includeInactive: showInactive,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    // Access control check
    if (!_hasAccess(userRole)) {
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
                'You don\'t have permission to view user list',
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          _buildUserStats(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'User List',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
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
            'View and manage all users',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          STITextField(
            labelText: 'Search users',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: _handleSearch,
          ),
          verticalSpace(8),
          Row(
            children: [
              FilterChip(
                label: const Text('Show Inactive'),
                selected: showInactive,
                onSelected: _handleToggleInactive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Consumer(
      builder: (context, ref, child) {
        final usersAsync = ref.watch(getUsersByRoleProvider(
          roleToGet: RoleConstants.santri,
          currentUserRole:
              ref.watch(userDataProvider).value?.role ?? RoleConstants.santri,
          includeInactive: true,
        ));

        return usersAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (users) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Users',
                  users.length.toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  'Active',
                  users.where((u) => u.isActive).length.toString(),
                  Icons.check_circle,
                  color: AppColors.success,
                ),
                _buildStatCard(
                  'Inactive',
                  users.where((u) => !u.isActive).length.toString(),
                  Icons.block,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            verticalSpace(4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer(
      builder: (context, ref, child) {
        final userRole = ref.watch(userDataProvider).value?.role;
        final usersAsync = ref.watch(getUsersByRoleProvider(
          roleToGet: RoleConstants.santri,
          currentUserRole: userRole ?? RoleConstants.santri,
          includeInactive: showInactive,
        ));

        return usersAsync.when(
          loading: () => const LoadingState(message: 'Loading users list...'),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: _handleRefresh,
          ),
          data: (users) {
            final filteredUsers = users.where((user) {
              final searchString = '${user.name} ${user.email}'.toLowerCase();
              return searchString.contains(searchQuery.toLowerCase());
            }).toList();

            if (filteredUsers.isEmpty) {
              return const EmptyState(
                message: 'No users found',
                icon: Icons.people_outline,
              );
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => verticalSpace(8),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : const AssetImage('assets/profile-placeholder.png')
                  as ImageProvider,
        ),
        title: Text(
          user.name,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoleBadgeWidget(role: user.role),
            if (!user.isActive)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.block, color: AppColors.error),
              ),
          ],
        ),
        onTap: () => _navigateToUserDetail(user.uid),
      ),
    );
  }
}
