import 'package:sti_app/domain/usecase/usecase.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/domain/usecase/authentication/upload_profile_picture/upload_profile_picture_params.dart';

class UploadProfilePicture
    implements Usecase<Result<User>, UploadProfilePictureParams> {
  final UserRepository _userRepository;

  UploadProfilePicture({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  @override
  Future<Result<User>> call(UploadProfilePictureParams params) async {
    try {
      // Validate file
      if (!params.imageFile.existsSync()) {
        return const Result.failed('File tidak ditemukan');
      }

      // Upload profile picture
      return _userRepository.uploadProfilePicture(
        user: params.user,
        imageFile: params.imageFile,
      );
    } catch (e) {
      return Result.failed('Gagal mengupload foto profil: ${e.toString()}');
    }
  }
}
