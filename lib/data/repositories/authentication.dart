import '../../domain/entities/result.dart';

abstract interface class Authentication {
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<Result<String>> login({
    required String email,
    required String password,
  });
  Future<Result<void>> logout();
  String? getLoggedUserId();
}
