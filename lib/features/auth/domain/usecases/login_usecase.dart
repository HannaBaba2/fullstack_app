import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/auth/domain/entities/user.dart';
import 'package:fullstack_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Result<User>> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
