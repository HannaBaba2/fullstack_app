import 'package:equatable/equatable.dart';

/// Failures are the "user-facing" counterpart of exceptions.
/// The repository layer converts exceptions -> failures so that the
/// presentation layer never has to deal with raw exceptions / Dio errors.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur. Reessayez plus tard.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expiree. Reconnectez-vous.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Impossible de lire les donnees en cache.']);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure([
    super.message = 'Pas de connexion internet. Affichage des donnees en cache si disponibles.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inconnue est survenue.']);
}
