import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Result<void>> call() => repository.logout();
}
