import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:fullstack_app/core/network/dio_client.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/core/storage/token_storage.dart';

import 'package:fullstack_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fullstack_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fullstack_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fullstack_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fullstack_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:fullstack_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fullstack_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:fullstack_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:fullstack_app/features/posts/data/datasources/posts_local_datasource.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:fullstack_app/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:fullstack_app/features/posts/domain/repositories/posts_repository.dart';
import 'package:fullstack_app/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:fullstack_app/features/posts/presentation/providers/posts_provider.dart';

import 'package:fullstack_app/features/albums/data/datasources/albums_local_datasource.dart';
import 'package:fullstack_app/features/albums/data/datasources/albums_remote_datasource.dart';
import 'package:fullstack_app/features/albums/data/repositories/albums_repository_impl.dart';
import 'package:fullstack_app/features/albums/domain/repositories/albums_repository.dart';
import 'package:fullstack_app/features/albums/domain/usecases/get_albums_usecase.dart';
import 'package:fullstack_app/features/albums/presentation/providers/albums_provider.dart';

import 'package:fullstack_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_remote_datasource.dart';
import 'package:fullstack_app/features/todos/data/repositories/todos_repository_impl.dart';
import 'package:fullstack_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:fullstack_app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:fullstack_app/features/todos/presentation/providers/todos_provider.dart';

final sl = GetIt.instance;

/// Registers every dependency of the app. Call once, before runApp().
/// Hive boxes must already be open (see main.dart) before this runs.
Future<void> initDependencyInjection() async {
  // ---- Core ----
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Two distinct Dio instances (different base URLs) are registered under
  // separate instance names since GetIt only allows one unnamed instance
  // per type.
  sl.registerLazySingleton<Dio>(
    () => DioClient.createAuthDio(),
    instanceName: 'authDio',
  );
  sl.registerLazySingleton<Dio>(
    () => DioClient.createDataDio(
      tokenStorage: sl(),
      onSessionExpired: () => sl<AuthProvider>().forceLogout(),
    ),
    instanceName: 'dataDio',
  );

  // ---- Auth feature ----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(instanceName: 'authDio')),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ---- Posts feature ----
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(sl(instanceName: 'dataDio')),
  );
  sl.registerLazySingleton<PostsLocalDataSource>(() => PostsLocalDataSourceImpl());
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerFactory(() => PostsProvider(sl()));

  // ---- Albums feature ----
  sl.registerLazySingleton<AlbumsRemoteDataSource>(
    () => AlbumsRemoteDataSourceImpl(sl(instanceName: 'dataDio')),
  );
  sl.registerLazySingleton<AlbumsLocalDataSource>(() => AlbumsLocalDataSourceImpl());
  sl.registerLazySingleton<AlbumsRepository>(
    () => AlbumsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetAlbumsUseCase(sl()));
  sl.registerFactory(() => AlbumsProvider(sl()));

  // ---- Todos feature ----
  sl.registerLazySingleton<TodosRemoteDataSource>(
    () => TodosRemoteDataSourceImpl(sl(instanceName: 'dataDio')),
  );
  sl.registerLazySingleton<TodosLocalDataSource>(() => TodosLocalDataSourceImpl());
  sl.registerLazySingleton<TodosRepository>(
    () => TodosRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetTodosUseCase(sl()));
  sl.registerFactory(() => TodosProvider(sl()));
}
