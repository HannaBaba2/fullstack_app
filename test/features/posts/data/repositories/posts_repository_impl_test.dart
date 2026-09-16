import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_local_datasource.dart';
import 'package:fullstack_app/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:fullstack_app/features/posts/data/models/post_model.dart';
import 'package:fullstack_app/features/posts/data/repositories/posts_repository_impl.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

class MockPostsLocalDataSource extends Mock implements PostsLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late PostsRepositoryImpl repository;
  late MockPostsRemoteDataSource remoteDataSource;
  late MockPostsLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUpAll(() {
    registerFallbackValue(<PostModel>[]);
  });

  setUp(() {
    remoteDataSource = MockPostsRemoteDataSource();
    localDataSource = MockPostsLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = PostsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  const tPosts = [
    PostModel(id: 1, userId: 1, title: 'Titre 1', body: 'Contenu 1'),
    PostModel(id: 2, userId: 1, title: 'Titre 2', body: 'Contenu 2'),
  ];

  test('en ligne : recupere les posts depuis le reseau et met a jour le cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remoteDataSource.getPosts()).thenAnswer((_) async => tPosts);
    when(() => localDataSource.cachePosts(tPosts)).thenAnswer((_) async {});

    final result = await repository.getPosts();

    expect(result.isSuccess, true);
    expect(result.data?.isFromCache, false);
    expect(result.data?.data.length, 2);
    verify(() => localDataSource.cachePosts(tPosts)).called(1);
  });

  test('hors ligne : retourne les donnees en cache avec isFromCache=true', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => localDataSource.getCachedPosts()).thenAnswer((_) async => tPosts);

    final result = await repository.getPosts();

    expect(result.isSuccess, true);
    expect(result.data?.isFromCache, true);
    expect(result.data?.data, tPosts);
    verifyNever(() => remoteDataSource.getPosts());
  });

  test('hors ligne sans cache disponible : retourne NoConnectionFailure', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => localDataSource.getCachedPosts())
        .thenThrow(CacheException('Aucune donnee en cache.'));

    final result = await repository.getPosts();

    expect(result.isError, true);
    expect(result.failure, isA<NoConnectionFailure>());
  });

  test('erreur serveur en ligne mais cache disponible : retourne quand meme les donnees', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remoteDataSource.getPosts()).thenThrow(ServerException('Erreur serveur.'));
    when(() => localDataSource.getCachedPosts()).thenAnswer((_) async => tPosts);

    final result = await repository.getPosts();

    expect(result.isSuccess, true);
    expect(result.data?.isFromCache, true);
  });
}
