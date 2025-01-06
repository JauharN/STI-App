import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/repositories/user_repository/user_repository_provider.dart';
import '../../../providers/usecases/user_management/get_users_by_role_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management_widget/role_management_item_widget.dart';
import '../../../extensions/extensions.dart';

class RoleManagementPage extends ConsumerStatefulWidget {
  const RoleManagementPage({super.key});

  @override
  ConsumerState<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends ConsumerState<RoleManagementPage> {
  // Filter state
  String searchQuery = '';
  UserRole selectedRole = UserRole.santri;
  bool showInactive = false;
  bool isProcessing = false;

  // Controllers
  final searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Role validation helper
  bool _canUpdateRole(UserRole currentRole, UserRole targetRole) {
    if (currentRole != UserRole.superAdmin) return false;
    if (targetRole == UserRole.superAdmin) return false;
    return true;
  }

  // Error handling with timeout and retry
  Future<bool> _handleRoleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = 3,
    int timeoutSeconds = 30,
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

  // Confirmation dialog
  Future<bool> _showConfirmationDialog(String action, String message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm $action',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  // Handlers
  void _handleRoleFilter(UserRole role) {
    setState(() {
      selectedRole = role;
      searchQuery = ''; // Reset search when changing role
      searchController.clear();
    });
  }

  void _handleSearch(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => searchQuery = query.trim());
    });
  }

  void _handleToggleInactive(bool? value) {
    setState(() => showInactive = value ?? false);
  }

  Future<void> _handleRoleUpdate(User user, UserRole newRole) async {
    if (!_canUpdateRole(
        ref.read(userDataProvider).value?.role ?? UserRole.santri, newRole)) {
      context
          .showErrorSnackBar('You don\'t have permission for this operation');
      return;
    }

    final confirmed = await _showConfirmationDialog('Update Role',
        'Are you sure you want to change ${user.name}\'s role to ${newRole.displayName}?');

    if (!confirmed) return;

    setState(() => isProcessing = true);
    try {
      final success = await _handleRoleOperationWithRetry(() async {
        final updatedUser = user.copyWith(role: newRole);
        final result = await ref
            .read(userRepositoryProvider)
            .updateUser(user: updatedUser);
        if (result.isFailed) {
          throw Exception(result.errorMessage);
        }
      });

      if (success && mounted) {
        context.showSuccessSnackBar('User role updated successfully');
        ref.refresh(getUsersByRoleProvider(
          roleToGet: selectedRole,
          currentUserRole:
              ref.read(userDataProvider).value?.role ?? UserRole.santri,
          includeInactive: showInactive,
        ));
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _handleToggleActive(User user) async {
    final action = user.isActive ? 'deactivate' : 'activate';
    final confirmed = await _showConfirmationDialog(
        'Toggle Status', 'Are you sure you want to $action ${user.name}?');

    if (!confirmed) return;

    setState(() => isProcessing = true);
    try {
      final success = await _handleRoleOperationWithRetry(() async {
        final updatedUser = user.copyWith(isActive: !user.isActive);
        final result = await ref
            .read(userRepositoryProvider)
            .updateUser(user: updatedUser);
        if (result.isFailed) {
          throw Exception(result.errorMessage);
        }
      });

      if (success && mounted) {
        context.showSuccessSnackBar('User status updated successfully');
        ref.refresh(getUsersByRoleProvider(
          roleToGet: selectedRole,
          currentUserRole:
              ref.read(userDataProvider).value?.role ?? UserRole.santri,
          includeInactive: showInactive,
        ));
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // UI Components
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage user roles and access permissions',
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          STITextField(
            labelText: 'Search users',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: _handleSearch,
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SegmentedButton<UserRole>(
                  segments: UserRole.values
                      .map((role) => ButtonSegment(
                            value: role,
                            label: Text(role.displayName),
                          ))
                      .toList(),
                  selected: {selectedRole},
                  onSelectionChanged: (Set<UserRole> roles) {
                    _handleRoleFilter(roles.first);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Show Inactive'),
                  selected: showInactive,
                  onSelected: _handleToggleInactive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserRole = ref.watch(userDataProvider).value?.role;
        if (currentUserRole != UserRole.superAdmin) {
          return const EmptyState(
            message: 'Only Super Admin can access role management',
            icon: Icons.admin_panel_settings,
          );
        }

        final usersAsync = ref.watch(
          getUsersByRoleProvider(
            roleToGet: selectedRole,
            currentUserRole: currentUserRole ?? UserRole.santri,
            includeInactive: showInactive,
          ),
        );

        return Stack(
          children: [
            usersAsync.when(
              loading: () => const LoadingState(message: 'Loading users...'),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.refresh(
                  getUsersByRoleProvider(
                    roleToGet: selectedRole,
                    currentUserRole: currentUserRole ?? UserRole.santri,
                    includeInactive: showInactive,
                  ),
                ),
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
                    message: 'No users found for selected role',
                    icon: Icons.group_off,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(
                    getUsersByRoleProvider(
                      roleToGet: selectedRole,
                      currentUserRole: currentUserRole ?? UserRole.santri,
                      includeInactive: showInactive,
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return RoleManagementItemWidget(
                        user: user,
                        onUpdateRole: (newRole) =>
                            _handleRoleUpdate(user, newRole),
                        onToggleActive: () => _handleToggleActive(user),
                      );
                    },
                  ),
                );
              },
            ),
            if (isProcessing)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(getUsersByRoleProvider(
              roleToGet: selectedRole,
              currentUserRole:
                  ref.read(userDataProvider).value?.role ?? UserRole.santri,
              includeInactive: showInactive,
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilters(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
