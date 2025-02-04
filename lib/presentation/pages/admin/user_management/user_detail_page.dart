import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/result.dart';
import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/repositories/user_repository/user_repository_provider.dart';
import '../../../providers/usecases/user_management/get_user_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../states/error_state.dart';
import '../../../states/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management_widget/role_badge_widget.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailPage({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // State variables
  bool isEditing = false;
  bool isLoading = false;
  DateTime? selectedDate;
  File? profileImage;
  String? error;

  // Focus nodes
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();

    super.dispose();
  }

  bool _canEdit(String? currentUserRole) {
    return currentUserRole == 'superAdmin';
  }

  bool _canManageRole(String? currentUserRole, String targetUserRole) {
    if (currentUserRole != 'superAdmin') return false;
    if (targetUserRole == 'superAdmin') return false;
    return true;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.getUser(uid: widget.userId);

      if (result case Success(value: final user)) {
        nameController.text = user.name;
        phoneController.text = user.phoneNumber ?? '';
        addressController.text = user.address ?? '';
        selectedDate = user.dateOfBirth;
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final currentUser = ref.read(getUserProvider(widget.userId)).value;

      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        name: nameController.text,
        phoneNumber: phoneController.text,
        address: addressController.text,
        dateOfBirth: selectedDate,
      );

      final result = await userRepository.updateUser(
        user: updatedUser,
      );

      if (result.isSuccess) {
        if (mounted) {
          setState(() => isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        ref.refresh(getUserProvider(widget.userId));
      } else {
        throw Exception(result.errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleUpdatePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() => profileImage = File(pickedImage.path));

        final currentUser = ref.read(getUserProvider(widget.userId)).value;
        if (currentUser != null) {
          final userRepository = ref.read(userRepositoryProvider);
          final result = await userRepository.uploadProfilePicture(
            user: currentUser,
            imageFile: File(pickedImage.path),
          );

          if (result.isSuccess) {
            ref.refresh(getUserProvider(widget.userId));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile picture updated'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            throw Exception(result.errorMessage);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateRole(String newRole) async {
    final currentUser = ref.read(userDataProvider).value;

    if (!_canManageRole(currentUser?.role, newRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have permission to change roles'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ref.read(userDataProvider.notifier).updateUserRole(
            uid: widget.userId,
            newRole: newRole,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User role updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.refresh(getUserProvider(widget.userId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleToggleActive() async {
    final currentUser = ref.read(getUserProvider(widget.userId)).value;
    if (currentUser == null) return;

    final userRole = ref.read(userDataProvider).value?.role;
    if (!_canManageRole(userRole, currentUser.role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have permission for this action'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          currentUser.isActive ? 'Deactivate User' : 'Activate User',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to ${currentUser.isActive ? 'deactivate' : 'activate'} this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentUser.isActive ? AppColors.error : AppColors.success,
            ),
            child: Text(currentUser.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);

      try {
        if (currentUser.isActive) {
          await ref
              .read(userDataProvider.notifier)
              .deactivateUser(currentUser.uid);
        } else {
          await ref
              .read(userDataProvider.notifier)
              .activateUser(currentUser.uid);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${currentUser.isActive ? 'Deactivated' : 'Activated'} user successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.refresh(getUserProvider(widget.userId));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update user status: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.neutral900,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != selectedDate) {
        setState(() => selectedDate = picked);
        if (isEditing) {
          await _handleSave();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update date: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRoleUpdateDialog(String currentRole) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          'Update Role',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RoleConstants.allRoles
              .where((role) => role != currentRole && role != 'superAdmin')
              .map(
                (role) => ListTile(
                  title: Text(RoleConstants.roleDisplayNames[role] ?? role),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _handleUpdateRole(role);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildContent(User user) {
    final currentUserRole = ref.watch(userDataProvider).value?.role;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserInfo(user),
          const SizedBox(height: 24),
          if (isEditing) _buildEditForm(),
          const SizedBox(height: 24),
          if (currentUserRole == 'superAdmin') _buildAdminActions(user),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutral100,
                  image: user.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.photoUrl == null
                    ? const Icon(Icons.person,
                        size: 50, color: AppColors.neutral400)
                    : null,
              ),
              if (isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _handleUpdatePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                user.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              RoleBadgeWidget(role: user.role),
              if (!user.isActive)
                Chip(
                  label: const Text('Inactive'),
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        STITextField(
          labelText: 'Full Name',
          controller: nameController,
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
          prefixIcon: const Icon(Icons.person_outline),
          validator: _validateName,
        ),
        const SizedBox(height: 16),
        STITextField(
          labelText: 'Phone Number',
          controller: phoneController,
          focusNode: _phoneFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _addressFocus.requestFocus(),
          prefixIcon: const Icon(Icons.phone_outlined),
          maxLength: 13,
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        STITextField(
          labelText: 'Address',
          controller: addressController,
          focusNode: _addressFocus,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.location_on_outlined),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                  : 'Select date of birth',
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => isEditing = false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminActions(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Admin Actions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showRoleUpdateDialog(user.role),
          icon: const Icon(Icons.admin_panel_settings),
          label: Text(
              'Change Role (Current: ${RoleConstants.roleDisplayNames[user.role] ?? user.role})'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _handleToggleActive,
          icon: Icon(user.isActive ? Icons.block : Icons.check_circle),
          label: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                user.isActive ? AppColors.error : AppColors.success,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(getUserProvider(widget.userId));
    final currentUserRole = ref.watch(userDataProvider).value?.role;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Detail',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEditing && _canEdit(currentUserRole))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: Stack(
        children: [
          userAsync.when(
            loading: () => const LoadingState(
              message: 'Loading user details...',
            ),
            error: (error, stack) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.refresh(getUserProvider(widget.userId)),
            ),
            data: (user) => _buildContent(user),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
