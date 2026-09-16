import 'package:flutter/foundation.dart';
import 'package:fullstack_app/features/todos/domain/entities/todo.dart';
import 'package:fullstack_app/features/todos/domain/usecases/get_todos_usecase.dart';

class TodosProvider extends ChangeNotifier {
  final GetTodosUseCase getTodosUseCase;
  TodosProvider(this.getTodosUseCase);

  List<Todo> todos = [];
  bool isLoading = false;
  bool isFromCache = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getTodosUseCase();
    isLoading = false;

    result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
      },
      (dataWithSource) {
        todos = dataWithSource.data;
        isFromCache = dataWithSource.isFromCache;
        notifyListeners();
      },
    );
  }
}
