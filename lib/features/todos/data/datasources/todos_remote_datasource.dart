import 'package:dio/dio.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/todos/data/models/todo_model.dart';

abstract class TodosRemoteDataSource {
  Future<List<TodoModel>> getTodos();
}

class TodosRemoteDataSourceImpl implements TodosRemoteDataSource {
  final Dio dio;
  TodosRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await dio.get('/todos', queryParameters: {'_limit': 50});
      final list = response.data as List;
      return list.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NoConnectionException();
      }
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.message ?? 'Erreur lors du chargement des todos.');
    }
  }
}
