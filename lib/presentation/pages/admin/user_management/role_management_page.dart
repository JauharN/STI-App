import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../misc/constants.dart';
import '../../../providers/presensi/admin/manage_santri_provider.dart';
import '../../../providers/usecases/user_management/get_users_by_role_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../states/empty_state.dart';
import '../../../states/error_state.dart';
import '../../../widgets/sti_text_field_widget.dart';

class RoleManagementPage extends ConsumerStatefulWidget {
  const RoleManagementPage({super.key});

  @override
  ConsumerState<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends ConsumerState<RoleManagementPage> {
  String searchQuery = '';
  String selectedRole = 'all';
  bool isProcessing = false;
  Timer? _filterDebounce;
  final searchController = TextEditingController();

  bool _canManageRoles(String? userRole) {
    return userRole == 'superAdmin';
  }

  Future<bool> _handleOperationWithRetry(
    Future<void> Function() operation, {
    int maxRetries = 3,
    int timeoutSeconds = 30,
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

  @override
  void dispose() {
    searchController.dispose();
    _filterDebounce?.cancel();
    super.dispose();
  }

  Future<void> _handleUpdateRole(
    String userId,
    String currentRole,
    String newRole,
  ) async {
    if (currentRole == 'superAdmin') {
      context.showErrorSnackBar('Cannot modify Super Admin role');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Role',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to change role from ${RoleConstants.roleDisplayNames[currentRole]} to ${RoleConstants.roleDisplayNames[newRole]}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isProcessing = true);

    try {
      final success = await _handleOperationWithRetry(() async {
        await ref.read(userDataProvider.notifier).updateUserRole(
              uid: userId,
              newRole: newRole,
            );
      });

      if (success && mounted) {
        context.showSuccessSnackBar('Role updated successfully');
        ref.refresh(manageSantriControllerProvider);
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _handleToggleActive(String userId, bool isActive) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isActive ? 'Deactivate User' : 'Activate User',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to ${isActive ? 'deactivate' : 'activate'} this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.error : AppColors.success,
            ),
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isProcessing = true);

    try {
      final success = await _handleOperationWithRetry(() async {
        if (isActive) {
          await ref.read(userDataProvider.notifier).deactivateUser(userId);
        } else {
          await ref.read(userDataProvider.notifier).activateUser(userId);
        }
      });

      if (success && mounted) {
        context.showSuccessSnackBar(
          '${isActive ? 'Deactivated' : 'Activated'} user successfully',
        );
        ref.refresh(manageSantriControllerProvider);
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userDataProvider).value?.role;

    if (!_canManageRoles(userRole)) {
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
                'Only Super Admin can access role management',
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
          'Role Management',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(manageSantriControllerProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              Expanded(child: _buildUserList()),
            ],
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage user roles and permissions',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          STITextField(
            labelText: 'Search users',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              _filterDebounce?.cancel();
              _filterDebounce = Timer(
                const Duration(milliseconds: 300),
                () => setState(() => searchQuery = value.trim()),
              );
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SegmentedButton<String>(
                  segments: [
                    const ButtonSegment(value: 'all', label: Text('All')),
                    ...RoleConstants.allRoles.map(
                      (role) => ButtonSegment(
                        value: role,
                        label:
                            Text(RoleConstants.roleDisplayNames[role] ?? role),
                      ),
                    ),
                  ],
                  selected: {selectedRole},
                  onSelectionChanged: (roles) {
                    setState(() => selectedRole = roles.first);
                  },
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
      builder: (context, ref, _) {
        final userRole = ref.watch(userDataProvider).value?.role ?? 'santri';
        final usersAsync = ref.watch(getUsersByRoleProvider(
          roleToGet:
              selectedRole, // Role sudah pasti string karena default 'all'
          currentUserRole: userRole,
          includeInactive: true,
        ));

        return usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.refresh(getUsersByRoleProvider(
              roleToGet: selectedRole,
              currentUserRole: userRole,
              includeInactive: true,
            )),
          ),
          data: (users) {
            final filteredList = users
                .where((user) =>
                    user.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    user.email
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            if (filteredList.isEmpty) {
              return const EmptyState(
                message: 'No users found',
                icon: Icons.group_off,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) =>
                  _buildUserCard(filteredList[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              itemBuilder: (context) => RoleConstants.allRoles
                  .where((role) => role != 'superAdmin' && role != user.role)
                  .map((role) => PopupMenuItem(
                        value: role,
                        child:
                            Text(RoleConstants.roleDisplayNames[role] ?? role),
                      ))
                  .toList(),
              onSelected: (newRole) =>
                  _handleUpdateRole(user.uid, user.role, newRole),
              child: Chip(
                label: Text(
                    RoleConstants.roleDisplayNames[user.role] ?? user.role),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
            IconButton(
              icon: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive ? AppColors.error : AppColors.success,
              ),
              onPressed: () => _handleToggleActive(user.uid, user.isActive),
            ),
          ],
        ),
      ),
    );
  }
}
