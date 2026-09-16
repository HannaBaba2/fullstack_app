import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_local_datasource.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:fullstack_app/features/posts/domain/entities/post.dart';
import 'package:fullstack_app/features/posts/domain/repositories/posts_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<DataWithSource<List<Post>>>> getPosts() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final posts = await remoteDataSource.getPosts();
        await localDataSource.cachePosts(posts);
        return Result.success(DataWithSource(data: posts, isFromCache: false));
      } on UnauthorizedException catch (e) {
        return Result.error(UnauthorizedFailure(e.message));
      } on ServerException catch (e) {
        return _fallbackToCache(ServerFailure(e.message));
      } catch (_) {
        return _fallbackToCache(const UnknownFailure());
      }
    }

    // Offline: serve cached data straight away.
    return _fallbackToCache(const NoConnectionFailure());
  }

  Future<Result<DataWithSource<List<Post>>>> _fallbackToCache(Failure originalFailure) async {
    try {
      final cached = await localDataSource.getCachedPosts();
      return Result.success(DataWithSource(data: cached, isFromCache: true));
    } on CacheException {
      return Result.error(originalFailure);
    }
  }
}
