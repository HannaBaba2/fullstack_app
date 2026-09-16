import 'package:dio/dio.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/api/login',
        data: {'email': email, 'password': password},
      );
      return UserModel(
        email: email,
        token: response.data['token'] as String,
        refreshToken: password, // demo backend has no real refresh token
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserModel> register({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/api/register',
        data: {'email': email, 'password': password},
      );
      return UserModel(
        email: email,
        token: response.data['token'] as String,
        refreshToken: password,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NoConnectionException();
    }
    if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Identifiants invalides.')
          : 'Identifiants invalides.';
      return UnauthorizedException(msg.toString());
    }
    return ServerException(e.message ?? 'Erreur serveur.');
  }
}
