import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_remote_datasource.dart';
import 'package:fullstack_app/features/todos/domain/entities/todo.dart';
import 'package:fullstack_app/features/todos/domain/repositories/todos_repository.dart';

class TodosRepositoryImpl implements TodosRepository {
  final TodosRemoteDataSource remoteDataSource;
  final TodosLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<DataWithSource<List<Todo>>>> getTodos() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final todos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(todos);
        return Result.success(DataWithSource(data: todos, isFromCache: false));
      } on UnauthorizedException catch (e) {
        return Result.error(UnauthorizedFailure(e.message));
      } on ServerException catch (e) {
        return _fallbackToCache(ServerFailure(e.message));
      } catch (_) {
        return _fallbackToCache(const UnknownFailure());
      }
    }

    return _fallbackToCache(const NoConnectionFailure());
  }

  Future<Result<DataWithSource<List<Todo>>>> _fallbackToCache(Failure originalFailure) async {
    try {
      final cached = await localDataSource.getCachedTodos();
      return Result.success(DataWithSource(data: cached, isFromCache: true));
    } on CacheException {
      return Result.error(originalFailure);
    }
  }
}
