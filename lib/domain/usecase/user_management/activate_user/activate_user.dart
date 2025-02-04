import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

part 'activate_user_params.dart';

class ActivateUser implements Usecase<Result<User>, ActivateUserParams> {
  final UserRepository _userRepository;

  ActivateUser({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(ActivateUserParams params) async {
    try {
      // Validasi role user yang melakukan aktivasi
      if (params.currentUserRole != 'superAdmin') {
        return const Result.failed(
            'Hanya Super Admin yang dapat mengaktifkan user');
      }

      // Dapatkan user yang akan diaktifkan
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(
            'Gagal mendapatkan data user: ${userResult.errorMessage}');
      }

      final user = userResult.resultValue!;

      // Cek apakah user sudah aktif
      if (user.isActive) {
        return Result.failed('User ${user.name} sudah dalam keadaan aktif');
      }

      // Aktifkan user
      final updatedUser = user.copyWith(isActive: true);
      final updateResult = await _userRepository.updateUser(user: updatedUser);

      // Handle hasil update
      if (updateResult.isSuccess) {
        return Result.success(updateResult.resultValue!);
      } else {
        return Result.failed(
            'Gagal mengaktifkan user: ${updateResult.errorMessage}');
      }
    } catch (e) {
      return Result.failed('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
