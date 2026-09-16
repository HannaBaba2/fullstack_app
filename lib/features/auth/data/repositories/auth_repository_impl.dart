import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fullstack_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fullstack_app/features/auth/domain/entities/user.dart';
import 'package:fullstack_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    if (!await networkInfo.isConnected) {
      return Result.error(const NoConnectionFailure());
    }
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      await localDataSource.saveSession(user);
      return Result.success(user);
    } on UnauthorizedException catch (e) {
      return Result.error(UnauthorizedFailure(e.message));
    } on NoConnectionException catch (e) {
      return Result.error(NoConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } catch (_) {
      return Result.error(const UnknownFailure());
    }
  }

  @override
  Future<Result<User>> register({required String email, required String password}) async {
    if (!await networkInfo.isConnected) {
      return Result.error(const NoConnectionFailure());
    }
    try {
      final user = await remoteDataSource.register(email: email, password: password);
      await localDataSource.saveSession(user);
      return Result.success(user);
    } on UnauthorizedException catch (e) {
      return Result.error(UnauthorizedFailure(e.message));
    } on NoConnectionException catch (e) {
      return Result.error(NoConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    } catch (_) {
      return Result.error(const UnknownFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearSession();
      return Result.success(null);
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    }
  }

  @override
  Future<User?> getCurrentUser() => localDataSource.getSession();
}
