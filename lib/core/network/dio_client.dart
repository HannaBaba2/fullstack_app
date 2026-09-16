import 'package:dio/dio.dart';
import 'package:fullstack_app/core/network/auth_interceptor.dart';
import 'package:fullstack_app/core/storage/token_storage.dart';

/// API base URLs. Centralised here so switching backend is a one-line change.
class ApiConfig {
  /// Fake JWT-style auth backend used for the certification demo.
  /// Any of the seeded reqres.in accounts works, e.g.
  /// email: eve.holt@reqres.in / password: cityslicka
  static const String authBaseUrl = 'https://reqres.in';

  /// Public, key-free REST API used for the 3 data screens
  /// (posts / albums / todos).
  static const String dataBaseUrl = 'https://jsonplaceholder.typicode.com';
}

class DioClient {
  static Dio createAuthDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.authBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'x-api-key': 'reqres-free-v1'},
      ),
    );
  }

  /// Data Dio instance with the auth interceptor attached, so every call
  /// to the data API carries the JWT and benefits from the refresh flow.
  static Dio createDataDio({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.dataBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: createAuthDio(),
        onSessionExpired: onSessionExpired,
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );

    return dio;
  }
}
