import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/domain/usecase/authentication/upload_profile_picture/upload_profile_picture_params.dart';

class UploadProfilePicture
    implements Usecase<Result<User>, UploadProfilePictureParams> {
  final UserRepository _userRepository;
  static const int _maxFileSizeMB = 5;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];

  UploadProfilePicture({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  @override
  Future<Result<User>> call(UploadProfilePictureParams params) async {
    try {
      final validationResult = await _validateFile(params.imageFile);
      if (!validationResult.$1) {
        return Result.failed(validationResult.$2);
      }

      debugPrint(
          'Starting profile picture upload for user: ${params.user.uid}');

      final result = await _userRepository.uploadProfilePicture(
        user: params.user,
        imageFile: params.imageFile,
      );

      if (result.isSuccess) {
        debugPrint('Profile picture uploaded successfully');
      } else {
        debugPrint('Failed to upload profile picture: ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return Result.failed('Failed to upload profile picture: ${e.toString()}');
    }
  }

  Future<(bool, String)> _validateFile(File file) async {
    try {
      if (!file.existsSync()) {
        return (false, 'File not found');
      }

      final size = await file.length();
      if (size > _maxFileSizeMB * 1024 * 1024) {
        return (false, 'File size exceeds $_maxFileSizeMB MB');
      }

      final extension = file.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        return (
          false,
          'Invalid file type. Allowed: ${_allowedExtensions.join(', ')}'
        );
      }

      return (true, '');
    } catch (e) {
      debugPrint('Error validating file: $e');
      return (false, 'File validation failed');
    }
  }
}
