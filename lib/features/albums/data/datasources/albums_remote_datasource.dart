import 'package:dio/dio.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/albums/data/models/album_model.dart';

abstract class AlbumsRemoteDataSource {
  Future<List<AlbumModel>> getAlbums();
}

class AlbumsRemoteDataSourceImpl implements AlbumsRemoteDataSource {
  final Dio dio;
  AlbumsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AlbumModel>> getAlbums() async {
    try {
      final response = await dio.get('/albums');
      final list = response.data as List;
      return list.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NoConnectionException();
      }
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur lors du chargement des albums.');
    }
  }
}
