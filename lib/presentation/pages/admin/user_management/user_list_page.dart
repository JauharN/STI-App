import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/usecases/user_management/get_users_by_role_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management/role_badge_widget.dart';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
      extra: {
        'fromUserList': true
      }, // Optional flag if needed for back navigation
    );
  }

  Future<void> _handleRefresh() async {
    ref.refresh(getUsersByRoleProvider(
      roleToGet: UserRole.santri,
      currentUserRole:
          ref.read(userDataProvider).value?.role ?? UserRole.santri,
      includeInactive: showInactive,
    ));
  }

  // UI Components
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: const Border(bottom: BorderSide(color: AppColors.neutral300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User List',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View and manage registered users',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          STITextField(
            labelText: 'Search users',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: _handleSearch,
          ),
          const SizedBox(height: 8),
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

  Widget _buildUserList() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserRole = ref.watch(userDataProvider).value?.role;

        final usersAsync = ref.watch(getUsersByRoleProvider(
          roleToGet: UserRole.santri, // Default to show santri
          currentUserRole: currentUserRole ?? UserRole.santri,
          includeInactive: showInactive,
        ));

        return usersAsync.when(
          loading: () => const LoadingState(message: 'Loading users list...'),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.refresh(getUsersByRoleProvider(
              roleToGet: UserRole.santri,
              currentUserRole: currentUserRole ?? UserRole.santri,
              includeInactive: showInactive,
            )),
          ),
          data: (users) {
            final filteredUsers = users
                .where((user) =>
                    user.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    user.email
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            if (filteredUsers.isEmpty) {
              return const EmptyState(
                message: 'No users found',
                icon: Icons.people_outline,
              );
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
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
                      trailing: RoleBadgeWidget(role: user.role),
                      onTap: () => _navigateToUserDetail(user.uid),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserStats() {
    return Consumer(
      builder: (context, ref, child) {
        final usersAsync = ref.watch(getUsersByRoleProvider(
          roleToGet: UserRole.santri,
          currentUserRole:
              ref.watch(userDataProvider).value?.role ?? UserRole.santri,
          includeInactive: true,
        ));

        return usersAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (users) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildUserStats(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
