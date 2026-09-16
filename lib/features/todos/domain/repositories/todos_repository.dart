import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/todos/domain/entities/todo.dart';

abstract class TodosRepository {
  Future<Result<DataWithSource<List<Todo>>>> getTodos();
}
