import 'package:hive_flutter/hive_flutter.dart';
import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/features/todos/data/models/todo_model.dart';

abstract class TodosLocalDataSource {
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<List<TodoModel>> getCachedTodos();
}

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  static const String boxName = 'todos_cache_box';
  static const String _key = 'todos';

  Box get _box => Hive.box(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final raw = todos.map((t) => t.toJson()).toList();
    await _box.put(_key, raw);
  }

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final raw = _box.get(_key);
    if (raw == null) throw CacheException('Aucune donnee en cache pour les todos.');
    final list = List<Map>.from(raw as List);
    return list.map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
