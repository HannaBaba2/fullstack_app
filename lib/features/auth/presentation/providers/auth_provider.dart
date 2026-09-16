import 'package:flutter/foundation.dart';
import 'package:fullstack_app/features/auth/domain/entities/user.dart';
import 'package:fullstack_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:fullstack_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fullstack_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:fullstack_app/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  });

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? errorMessage;
  bool isLoading = false;

  Future<void> checkSession() async {
    final current = await authRepository.getCurrentUser();
    user = current;
    status = current != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email: email, password: password);
    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (loggedUser) {
        user = loggedUser;
        status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await registerUseCase(email: email, password: password);
    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (registeredUser) {
        user = registeredUser;
        status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by the Dio interceptor when a refresh attempt fails.
  Future<void> forceLogout() async {
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
