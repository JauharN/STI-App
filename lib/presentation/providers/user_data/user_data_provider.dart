import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/result.dart';
import '../../../domain/usecase/authentication/login/login.dart';
import '../../../domain/usecase/authentication/register/register_params.dart';
import '../../../domain/usecase/authentication/upload_profile_picture/upload_profile_picture_params.dart';
import '../usecases/authentication/get_logged_user_id_provider.dart';
import '../usecases/authentication/login_provider.dart';
import '../usecases/authentication/logout_provider.dart';
import '../usecases/authentication/register_provider.dart';
import '../usecases/authentication/upload_profile_picture_provider.dart';

part 'user_data_provider.g.dart';

@Riverpod(keepAlive: true)
class UserData extends _$UserData {
  @override
  Future<User?> build() async {
    // Coba ambil user yang sedang login saat aplikasi dibuka
    final getLoggedUserId = ref.read(getLoggedUserIdProvider);
    var userResult = await getLoggedUserId(null);

    switch (userResult) {
      case Success(value: final user):
        return user;
      case Failed(message: _):
        return null;
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
      case Failed(:final message):
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
    }
  }

  // Method untuk register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role, // 'admin' atau 'santri'
    String? photoUrl,
  }) async {
    // Set state loading
    state = const AsyncLoading();

    // Ambil register usecase dari provider
    final register = ref.read(registerProvider);

    // Lakukan registrasi
    var result = await register(RegisterParams(
      name: name,
      email: email,
      password: password,
      role: role,
      photoUrl: photoUrl,
    ));

    // Handle hasil registrasi
    switch (result) {
      case Success(value: final user):
        // Jika sukses, update state dengan data user
        state = AsyncData(user);
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state ke null
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = const AsyncData(null);
    }
  }

  // Method untuk refresh data user
  Future<void> refreshUserData() async {
    final getLoggedUserId = ref.read(getLoggedUserIdProvider);
    var result = await getLoggedUserId(null);

    if (result case Success(value: final user)) {
      state = AsyncData(user);
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
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
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
      case Failed(:final message):
        // Jika gagal, set error dan kembalikan state sebelumnya
        state = AsyncError(FlutterError(message), StackTrace.current);
        state = AsyncData(state.valueOrNull);
    }
  }
}
