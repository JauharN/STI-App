import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/entities/user_management/activate_user.dart';
import '../../../domain/entities/user_management/deactivate_user.dart';
import '../../../domain/usecase/authentication/login/login.dart';
import '../../../domain/usecase/authentication/register/register_params.dart';
import '../../../domain/usecase/authentication/upload_profile_picture/upload_profile_picture_params.dart';
import '../../../domain/usecase/user_management/update_user_role.dart/update_user_role.dart';
import '../usecases/authentication/get_logged_user_id_provider.dart';
import '../usecases/authentication/login_provider.dart';
import '../usecases/authentication/logout_provider.dart';
import '../usecases/authentication/register_provider.dart';
import '../usecases/authentication/upload_profile_picture_provider.dart';
import '../usecases/user_management/activate_user_provider.dart';
import '../usecases/user_management/deactivate_user_provider.dart';
import '../usecases/user_management/update_user_role_provider.dart';

part 'user_data_provider.g.dart';

@Riverpod(keepAlive: true)
class UserData extends _$UserData {
  final _streamController = StreamController<User?>.broadcast();

  Stream<User?> userStateStream() => _streamController.stream;

  @override
  Future<User?> build() async {
    ref.onDispose(() {
      _streamController.close();
    });

    final getLoggedUserId = ref.read(getLoggedUserIdProvider);
    var userResult = await getLoggedUserId(null);

    final user = switch (userResult) {
      Success(value: final user) => user,
      Failed(message: _) => null,
    };

    _notifyStateChange(user);
    return user;
  }

  void _notifyStateChange(User? user) {
    if (!_streamController.isClosed) {
      _streamController.add(user);
    }
  }

  // Method untuk login
  Future<void> login(
      {required String email,
      required String password,
      bool rememberMe = false}) async {
    // Set state loading
    state = const AsyncLoading();

    // Ambil login usecase dari provider
    final login = ref.read(loginProvider);

    // Lakukan login
    var result = await login(LoginParams(
      email: email,
      password: password,
    ));

    // Handle hasil login
    switch (result) {
      case Success(value: final user):
        // Simpan ke SharedPreferences jika rememberMe true
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
          await prefs.setString('userPassword', password);
        }
        state = AsyncData(user);
        _notifyStateChange(user);

      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
        _notifyStateChange(null);
    }
  }

  // Method untuk register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    String? photoUrl,
  }) async {
    state = const AsyncLoading();

    final register = ref.read(registerProvider);
    var result = await register(RegisterParams(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      address: address,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
    ));

    switch (result) {
      case Success(value: final user):
        state = AsyncData(user);
        _notifyStateChange(user);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
        _notifyStateChange(null);
    }
  }

  // Method untuk refresh data user
  Future<void> refreshUserData() async {
    final getLoggedUserId = ref.read(getLoggedUserIdProvider);
    var result = await getLoggedUserId(null);

    if (result case Success(value: final user)) {
      state = AsyncData(user);
      _notifyStateChange(user);
    }
  }

  // Method untuk logout
  Future<void> logout() async {
    final logout = ref.read(logoutProvider);
    var result = await logout(null);

    switch (result) {
      case Success(value: _):
        // Jika sukses, set state ke null
        state = const AsyncData(null);
        _notifyStateChange(null);
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
        _notifyStateChange(state.valueOrNull);
    }
  }

  // Method untuk upload foto profil
  Future<void> uploadProfilePicture({
    required User user,
    required File imageFile,
  }) async {
    // Set state loading
    state = const AsyncLoading();

    // Ambil upload profile picture usecase dari provider
    final uploadProfilePicture = ref.read(uploadProfilePictureProvider);

    // Upload foto profil
    var result = await uploadProfilePicture(
      UploadProfilePictureParams(
        user: user,
        imageFile: imageFile,
      ),
    );

    // Handle hasil upload
    switch (result) {
      case Success(value: final updatedUser):
        // Jika sukses, update state dengan data user yang baru
        state = AsyncData(updatedUser);
        _notifyStateChange(updatedUser);
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
        _notifyStateChange(state.valueOrNull);
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required UserRole newRole,
  }) async {
    state = const AsyncLoading();
    final currentUser = state.valueOrNull;

    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      return;
    }

    final updateRole = ref.read(updateUserRoleProvider);
    final result = await updateRole(UpdateUserRoleParams(
      uid: uid,
      newRole: newRole,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }

  Future<void> activateUser(String uid) async {
    state = const AsyncLoading();
    final currentUser = state.valueOrNull;

    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      return;
    }

    final activate = ref.read(activateUserProvider);
    final result = await activate(ActivateUserParams(
      uid: uid,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }

  Future<void> deactivateUser(String uid) async {
    state = const AsyncLoading();
    final currentUser = state.valueOrNull;

    if (currentUser == null) {
      state = const AsyncData(null);
      _notifyStateChange(null);
      return;
    }

    final deactivate = ref.read(deactivateUserProvider);
    final result = await deactivate(DeactivateUserParams(
      uid: uid,
      currentUserRole: currentUser.role,
    ));

    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        _notifyStateChange(value);
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(currentUser);
        _notifyStateChange(currentUser);
    }
  }
}
