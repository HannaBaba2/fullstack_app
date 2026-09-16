import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fullstack_app/core/error/exceptions.dart';
import 'package:fullstack_app/core/error/failures.dart';
import 'package:fullstack_app/core/network/network_info.dart';
import 'package:fullstack_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fullstack_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fullstack_app/features/auth/data/models/user_model.dart';
import 'package:fullstack_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  const tEmail = 'eve.holt@reqres.in';
  const tPassword = 'cityslicka';
  const tUserModel = UserModel(
    email: tEmail,
    token: 'QpwL5tke4Pnpja7X4',
    refreshToken: tPassword,
  );

  group('login', () {
    test(
      'retourne un User et sauvegarde la session quand le reseau est disponible '
      'et les identifiants valides',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.login(email: tEmail, password: tPassword))
            .thenAnswer((_) async => tUserModel);
        when(() => localDataSource.saveSession(tUserModel)).thenAnswer((_) async {});

        final result = await repository.login(email: tEmail, password: tPassword);

        expect(result.isSuccess, true);
        expect(result.data?.email, tEmail);
        verify(() => localDataSource.saveSession(tUserModel)).called(1);
      },
    );

    test('retourne NoConnectionFailure quand il n\'y a pas de reseau', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login(email: tEmail, password: tPassword);

      expect(result.isError, true);
      expect(result.failure, isA<NoConnectionFailure>());
      verifyNever(
        () => remoteDataSource.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('retourne UnauthorizedFailure quand les identifiants sont invalides', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.login(email: tEmail, password: tPassword))
          .thenThrow(UnauthorizedException('Identifiants invalides.'));

      final result = await repository.login(email: tEmail, password: tPassword);

      expect(result.isError, true);
      expect(result.failure, isA<UnauthorizedFailure>());
      verifyNever(() => localDataSource.saveSession(any()));
    });
  });

  group('logout', () {
    test('efface la session locale et retourne un succes', () async {
      when(() => localDataSource.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isSuccess, true);
      verify(() => localDataSource.clearSession()).called(1);
    });
  });
}
