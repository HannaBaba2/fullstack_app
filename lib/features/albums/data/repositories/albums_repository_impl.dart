import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/albums/data/datasources/albums_local_datasource.dart';
import 'package:fullstack_app/features/albums/data/datasources/albums_remote_datasource.dart';
import 'package:fullstack_app/features/albums/domain/entities/album.dart';
import 'package:fullstack_app/features/albums/domain/repositories/albums_repository.dart';

class AlbumsRepositoryImpl implements AlbumsRepository {
  final AlbumsRemoteDataSource remoteDataSource;
  final AlbumsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AlbumsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<DataWithSource<List<Album>>>> getAlbums() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final albums = await remoteDataSource.getAlbums();
        await localDataSource.cacheAlbums(albums);
        return Result.success(DataWithSource(data: albums, isFromCache: false));
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

  Future<Result<DataWithSource<List<Album>>>> _fallbackToCache(Failure originalFailure) async {
    try {
      final cached = await localDataSource.getCachedAlbums();
      return Result.success(DataWithSource(data: cached, isFromCache: true));
    } on CacheException {
      return Result.error(originalFailure);
    }
  }
}
