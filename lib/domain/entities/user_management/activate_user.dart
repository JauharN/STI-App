import 'package:sti_app/domain/entities/result.dart';
import 'package:sti_app/domain/entities/user.dart';
import 'package:sti_app/data/repositories/user_repository.dart';
import 'package:sti_app/domain/usecase/usecase.dart';

// Parameter class untuk ActivateUser usecase
class ActivateUserParams {
  final String uid;
  final UserRole currentUserRole; // Role dari user yang melakukan aktivasi

  ActivateUserParams({
    required this.uid,
    required this.currentUserRole,
  });
}

class ActivateUser implements Usecase<Result<User>, ActivateUserParams> {
  final UserRepository _userRepository;

  ActivateUser({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<User>> call(ActivateUserParams params) async {
    try {
      // Validasi hak akses
      if (params.currentUserRole != UserRole.superAdmin) {
        return const Result.failed(
            'Hanya Super Admin yang dapat mengaktifkan user');
      }

      // Dapatkan user yang akan diaktifkan
      final userResult = await _userRepository.getUser(uid: params.uid);

      if (userResult.isFailed) {
        return Result.failed(userResult.errorMessage!);
      }

      final user = userResult.resultValue!;

      // Jika user sudah aktif
      if (user.isActive) {
        return const Result.failed('User sudah dalam keadaan aktif');
      }

      // Aktifkan user
      final updatedUser = user.copyWith(isActive: true);

      return await _userRepository.updateUser(user: updatedUser);
    } catch (e) {
      return Result.failed('Gagal mengaktifkan user: ${e.toString()}');
    }
  }
}
