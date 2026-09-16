import 'package:dio/dio.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/posts/data/models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final Dio dio;
  PostsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get('/posts');
      final list = response.data as List;
      return list.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NoConnectionException();
      }
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur lors du chargement des posts.');
    }
  }
}
