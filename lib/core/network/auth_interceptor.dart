import 'package:dio/dio.dart';
import 'package:fullstack_app/core/storage/token_storage.dart';

/// Injects `Authorization: Bearer <token>` on every outgoing request and
/// attempts a token refresh when the API answers 401.
///
/// The demo backend (reqres.in) does not implement a real refresh-token
/// endpoint, so [_attemptRefresh] simulates the flow structurally: it reads
/// the stored refresh token and re-issues the login call. Swap the body of
/// [_attemptRefresh] for your real `/auth/refresh` endpoint when you plug in
/// your own backend - the rest of the interceptor (queueing, retry, logout
/// on failure) does not need to change.
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio refreshDio;
  final Future<void> Function() onSessionExpired;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshDio,
    required this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.extra['isRefreshCall'] == true;

    if (isUnauthorized && !isRefreshCall && !_isRefreshing) {
      _isRefreshing = true;
      final refreshed = await _attemptRefresh();
      _isRefreshing = false;

      if (refreshed) {
        // Retry the original request with the new token.
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${tokenStorage.accessToken}';
        try {
          final response = await refreshDio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // fall through to session expired below
        }
      }

      await tokenStorage.clear();
      await onSessionExpired();
    }

    handler.next(err);
  }

  Future<bool> _attemptRefresh() async {
    final refreshToken = tokenStorage.refreshToken;
    final email = tokenStorage.userEmail;
    if (refreshToken == null || email == null) return false;

    try {
      final response = await refreshDio.post(
        '/api/login',
        data: {'email': email, 'password': refreshToken},
        options: Options(extra: {'isRefreshCall': true}),
      );
      final newToken = response.data['token'] as String?;
      if (newToken == null) return false;
      await tokenStorage.saveSession(
        accessToken: newToken,
        refreshToken: refreshToken,
        email: email,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
