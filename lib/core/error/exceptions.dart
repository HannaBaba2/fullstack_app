/// Exceptions thrown by data sources (remote / local).
/// Repositories catch these and translate them into [Failure]s.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Erreur serveur inattendue.']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expiree, veuillez vous reconnecter.']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Erreur de lecture du cache local.']);
}

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'Pas de connexion internet.']);
}
