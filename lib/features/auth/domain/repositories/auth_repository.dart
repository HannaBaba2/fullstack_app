import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User>> register({required String email, required String password});
  Future<Result<void>> logout();
  Future<User?> getCurrentUser();
}
