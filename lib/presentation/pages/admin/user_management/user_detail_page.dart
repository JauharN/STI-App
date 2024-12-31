import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sti_app/presentation/extensions/extensions.dart';

import '../../../../domain/entities/user.dart';
import '../../../misc/constants.dart';
import '../../../providers/repositories/user_repository/user_repository_provider.dart';
import '../../../providers/usecases/user_management/get_user_provider.dart';
import '../../../providers/user_data/user_data_provider.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/sti_text_field_widget.dart';
import '../../../widgets/user_management/role_badge_widget.dart';

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
  // Form key
  final _formKey = GlobalKey<FormState>();
  late final AsyncValue<User> userAsync;

  // Controllers
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  // State variables
  bool isEditing = false;
  DateTime? selectedDate;
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
  }

  void _updateControllers(User user) {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? '';
    addressController.text = user.address ?? '';
    selectedDate = user.dateOfBirth;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(getUserProvider(widget.userId)).value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: nameController.text,
      phoneNumber: phoneController.text,
      address: addressController.text,
      dateOfBirth: selectedDate,
    );

    try {
      final result = await ref.read(userRepositoryProvider).updateUser(
            user: updatedUser,
          );

      if (result.isSuccess) {
        setState(() => isEditing = false);
        ref.refresh(getUserProvider(widget.userId));
      } else {
        // Show error
        if (context.mounted) {
          context.showSnackBar(result.errorMessage!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update user');
      }
    }
  }

  Future<void> _handleUpdatePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final currentUser = ref.read(getUserProvider(widget.userId)).value;
      if (currentUser == null) return;

      final file = File(image.path);
      final result =
          await ref.read(userRepositoryProvider).uploadProfilePicture(
                user: currentUser,
                imageFile: file,
              );

      if (result.isSuccess) {
        ref.refresh(getUserProvider(widget.userId));
      } else {
        if (context.mounted) {
          context.showSnackBar(result.errorMessage!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update profile picture');
      }
    }
  }

  Future<void> _handleUpdateRole() async {
    // Only SuperAdmin can update roles
    final currentUserRole = ref.read(userDataProvider).value?.role;
    if (currentUserRole != UserRole.superAdmin) {
      context.showSnackBar('Only Super Admin can change roles');
      return;
    }

    final currentUser = ref.read(getUserProvider(widget.userId)).value;
    if (currentUser == null) return;

    // Don't allow changing SuperAdmin role
    if (currentUser.role == UserRole.superAdmin) {
      context.showSnackBar('Cannot modify Super Admin role');
      return;
    }

    // Show role selection dialog
    final newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current role: ${currentUser.role.displayName}'),
            const SizedBox(height: 16),
            ...UserRole.values
                .where((role) =>
                    role != UserRole.superAdmin) // Can't assign superAdmin
                .map(
                  (role) => ListTile(
                    title: Text(role.displayName),
                    onTap: () => Navigator.pop(context, role),
                  ),
                ),
          ],
        ),
      ),
    );

    if (newRole == null) return;

    try {
      final updatedUser = currentUser.copyWith(role: newRole);
      final result = await ref.read(userRepositoryProvider).updateUser(
            user: updatedUser,
          );

      if (result.isSuccess) {
        ref.refresh(getUserProvider(widget.userId));
      } else {
        if (context.mounted) {
          context.showSnackBar(result.errorMessage!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update user role');
      }
    }
  }

  Future<void> _handleToggleActive() async {
    final currentUserRole = ref.read(userDataProvider).value?.role;
    if (currentUserRole != UserRole.superAdmin) {
      context.showSnackBar('Only Super Admin can modify user status');
      return;
    }

    final currentUser = ref.read(getUserProvider(widget.userId)).value;
    if (currentUser == null) return;

    // Don't allow deactivating SuperAdmin
    if (currentUser.role == UserRole.superAdmin) {
      context.showSnackBar('Cannot deactivate Super Admin');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentUser.isActive ? 'Deactivate User' : 'Activate User',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to ${currentUser.isActive ? 'deactivate' : 'activate'} ${currentUser.name}?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentUser.isActive ? AppColors.error : AppColors.success,
            ),
            child: Text(
              currentUser.isActive ? 'Deactivate' : 'Activate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updatedUser = currentUser.copyWith(isActive: !currentUser.isActive);
      final result = await ref.read(userRepositoryProvider).updateUser(
            user: updatedUser,
          );

      if (result.isSuccess) {
        ref.refresh(getUserProvider(widget.userId));
      } else {
        if (context.mounted) {
          context.showSnackBar(result.errorMessage!);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update user status');
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
        builder: (context, child) {
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
        setState(() {
          selectedDate = picked;
        });

        // Automatically save if user updates date without editing other fields
        if (!isEditing) {
          final currentUser = ref.read(getUserProvider(widget.userId)).value;
          if (currentUser == null) return;

          final updatedUser = currentUser.copyWith(dateOfBirth: picked);
          final result = await ref.read(userRepositoryProvider).updateUser(
                user: updatedUser,
              );

          if (result.isFailed && context.mounted) {
            context.showSnackBar(result.errorMessage!);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update date of birth');
      }
    }
  }

  Widget _buildUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : const AssetImage('assets/profile-placeholder.png')
                        as ImageProvider,
              ),
              if (isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _handleUpdatePhoto,
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
          labelText: 'Nama Lengkap',
          controller: nameController,
          focusNode: _nameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
          prefixIcon: const Icon(Icons.person_outline),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),

        STITextField(
          labelText: 'Nomor Telepon',
          controller: phoneController,
          focusNode: _phoneFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _addressFocus.requestFocus(),
          prefixIcon: const Icon(Icons.phone_outlined),
          maxLength: 13,
          validator: (value) {
            if (value?.isEmpty ?? true) return null; // Optional
            if (value!.length < 10) return 'Nomor telepon minimal 10 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),

        STITextField(
          labelText: 'Alamat',
          controller: addressController,
          focusNode: _addressFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSave(),
          prefixIcon: const Icon(Icons.location_on_outlined),
          maxLines: 2,
        ),
        // Date picker
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Lahir',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                  : 'Pilih tanggal lahir',
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Save & Cancel buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Simpan'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => isEditing = false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Batal'),
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

        // Role update button
        OutlinedButton.icon(
          onPressed: _handleUpdateRole,
          icon: const Icon(Icons.admin_panel_settings),
          label: Text('Change Role (Current: ${user.role.displayName})'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),

        // Active/Inactive toggle
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

  Widget _buildContent(User user) {
    _updateControllers(user);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserInfo(user),
          const SizedBox(height: 24),
          if (isEditing) _buildEditForm(),
          const SizedBox(height: 24),
          if (ref.watch(userDataProvider).value?.role == UserRole.superAdmin)
            _buildAdminActions(user),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(getUserProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Detail'),
        actions: [
          if (!isEditing &&
              ref.watch(userDataProvider).value?.role == UserRole.superAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const LoadingState(
          message: 'Loading user details...',
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(getUserProvider(widget.userId)),
        ),
        data: (user) => _buildContent(user),
      ),
    );
  }
}
