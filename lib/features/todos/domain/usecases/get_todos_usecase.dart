import 'package:fullstack_app/core/utils/data_source_info.dart';
import 'package:fullstack_app/core/utils/result.dart';
import 'package:fullstack_app/features/todos/domain/entities/todo.dart';
import 'package:fullstack_app/features/todos/domain/repositories/todos_repository.dart';

class GetTodosUseCase {
  final TodosRepository repository;
  GetTodosUseCase(this.repository);

  Future<Result<DataWithSource<List<Todo>>>> call() => repository.getTodos();
}
