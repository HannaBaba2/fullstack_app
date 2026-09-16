import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over device connectivity so it can be mocked in tests
/// and so repositories don't depend directly on a plugin.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // `connectivity_plus` changed checkConnectivity()'s return type between
    // major versions: it used to return a single ConnectivityResult and now
    // returns a List<ConnectivityResult> (multiple simultaneous interfaces).
    // Reading the result as `dynamic` keeps this code compiling against
    // either version instead of pinning an exact one.
    final dynamic result = await connectivity.checkConnectivity();
    if (result is List<ConnectivityResult>) {
      return !result.contains(ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }
}
