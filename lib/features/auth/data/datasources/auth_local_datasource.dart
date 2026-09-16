import 'package:fullstack_app/core/storage/token_storage.dart';
import 'package:fullstack_app/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(UserModel user);
  Future<UserModel?> getSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorage tokenStorage;
  AuthLocalDataSourceImpl(this.tokenStorage);

  @override
  Future<void> saveSession(UserModel user) => tokenStorage.saveSession(
        accessToken: user.token,
        refreshToken: user.refreshToken,
        email: user.email,
      );

  @override
  Future<UserModel?> getSession() async {
    final token = tokenStorage.accessToken;
    final email = tokenStorage.userEmail;
    if (token == null || email == null) return null;
    return UserModel(email: email, token: token, refreshToken: tokenStorage.refreshToken);
  }

  @override
  Future<void> clearSession() => tokenStorage.clear();
}
