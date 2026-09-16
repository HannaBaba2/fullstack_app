import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:fullstack_app/features/todos/data/datasources/todos_remote_datasource.dart';
import 'package:fullstack_app/features/todos/data/models/todo_model.dart';
import 'package:fullstack_app/features/todos/data/repositories/todos_repository_impl.dart';

class MockTodosRemoteDataSource extends Mock implements TodosRemoteDataSource {}

class MockTodosLocalDataSource extends Mock implements TodosLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late TodosRepositoryImpl repository;
  late MockTodosRemoteDataSource remoteDataSource;
  late MockTodosLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUpAll(() {
    registerFallbackValue(<TodoModel>[]);
  });

  setUp(() {
    remoteDataSource = MockTodosRemoteDataSource();
    localDataSource = MockTodosLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = TodosRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  const tTodos = [
    TodoModel(id: 1, userId: 1, title: 'Faire les courses', completed: false),
    TodoModel(id: 2, userId: 1, title: 'Reviser Flutter', completed: true),
  ];

  test('en ligne : recupere les todos depuis le reseau et met a jour le cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remoteDataSource.getTodos()).thenAnswer((_) async => tTodos);
    when(() => localDataSource.cacheTodos(tTodos)).thenAnswer((_) async {});

    final result = await repository.getTodos();

    expect(result.isSuccess, true);
    expect(result.data?.isFromCache, false);
    expect(result.data?.data.where((t) => t.completed).length, 1);
    verify(() => localDataSource.cacheTodos(tTodos)).called(1);
  });

  test('hors ligne : sert les todos depuis le cache local', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => localDataSource.getCachedTodos()).thenAnswer((_) async => tTodos);

    final result = await repository.getTodos();

    expect(result.isSuccess, true);
    expect(result.data?.isFromCache, true);
    verifyNever(() => remoteDataSource.getTodos());
  });

  test('token invalide (401) : retourne UnauthorizedFailure sans toucher au cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remoteDataSource.getTodos()).thenThrow(UnauthorizedException());

    final result = await repository.getTodos();

    expect(result.isError, true);
    expect(result.failure, isA<UnauthorizedFailure>());
    verifyNever(() => localDataSource.cacheTodos(any()));
  });
}
