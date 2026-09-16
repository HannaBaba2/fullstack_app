import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fullstack_app/core/di/injector.dart';
import 'package:fullstack_app/core/storage/token_storage.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_local_datasource.dart';
import 'package:fullstack_app/features/albums/data/datasources/albums_local_datasource.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:fullstack_app/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await TokenStorage.openBox();
  await PostsLocalDataSourceImpl.openBox();
  await AlbumsLocalDataSourceImpl.openBox();
  await TodosLocalDataSourceImpl.openBox();

  await initDependencyInjection();

  runApp(const App());
}
