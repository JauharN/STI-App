import 'dart:io';
import '../../../entities/user.dart';

class UploadProfilePictureParams {
  final User user;
  final File imageFile;

  UploadProfilePictureParams({
    required this.user,
    required this.imageFile,
  });
}
