import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kLoggedIn = 'is_logged_in';
  static const _kUserId = 'current_user_id';
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kLastSyncToken = 'last_sync_token';
  static const _kRole = 'current_user_role';

  Future<void> saveSession({
    required int userId,
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLoggedIn, true);
    await p.setInt(_kUserId, userId);
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
    if (role != null) {
      await p.setString(_kRole, role);
    }
  }

  Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLoggedIn) ?? false;
  }

  Future<int?> currentUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kUserId);
  }

  Future<String?> accessToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAccess);
  }

  Future<String?> refreshToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kRefresh);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
  }

  Future<String?> lastSyncToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kLastSyncToken);
  }

  Future<void> setLastSyncToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLastSyncToken, token);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kLoggedIn);
    await p.remove(_kUserId);
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kLastSyncToken);
    await p.remove(_kRole);
  }

  Future<String?> currentUserRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kRole);
  }
}
