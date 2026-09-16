import 'package:hive_flutter/hive_flutter.dart';

/// Stores the access token / refresh token / logged-in user email in a
/// dedicated Hive box. Kept separate from the data-caching boxes so that
/// clearing the auth box on logout never touches cached API data.
class TokenStorage {
  static const String boxName = 'auth_box';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';

  Box get _box => Hive.box(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required String email,
  }) async {
    await _box.put(_accessTokenKey, accessToken);
    if (refreshToken != null) await _box.put(_refreshTokenKey, refreshToken);
    await _box.put(_userEmailKey, email);
  }

  String? get accessToken => _box.get(_accessTokenKey) as String?;
  String? get refreshToken => _box.get(_refreshTokenKey) as String?;
  String? get userEmail => _box.get(_userEmailKey) as String?;

  bool get isLoggedIn => accessToken != null;

  Future<void> clear() async => _box.clear();
}
