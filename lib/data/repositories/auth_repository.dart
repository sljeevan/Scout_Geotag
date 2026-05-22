import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../local/app_db.dart';
import '../local/session_store.dart';
import '../models/user_local.dart';
import '../remote/sitepin_api_client.dart';

class AuthRepository {
  final SitePinApiClient api;
  final SessionStore sessionStore;

  AuthRepository({required this.api, required this.sessionStore});

  Future<int> login(
      {required String email,
      required String password,
      required String deviceId}) async {
    final res = await api.post('api/v1/auth/login', {
      'email': email.trim(),
      'password': password,
      'deviceId': deviceId,
    });

    final user = res['user'] as Map<String, dynamic>;
    int localId;
    if (kIsWeb) {
      localId = (user['email'] as String).hashCode & 0x7fffffff;
    } else {
      final db = await AppDb.instance;
      await db.insert(
        'users',
        LocalUser(
          email: user['email'] as String,
          orgId: user['orgId'] as String,
          role: user['role'] as String,
          isActive: (user['isActive'] ?? true) as bool,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final local = await db.query('users',
          where: 'email = ?', whereArgs: [user['email']], limit: 1);
      localId = local.first['id'] as int;
    }

    await sessionStore.saveSession(
      userId: localId,
      accessToken: res['accessToken'] as String,
      refreshToken: res['refreshToken'] as String,
      role: user['role'] as String?,
    );
    return localId;
  }

  Future<int?> register({
    required String email,
    required String password,
    required String orgId,
    required String role,
  }) async {
    final res = await api.post('api/v1/auth/register', {
      'email': email.trim(),
      'password': password,
      'orgId': orgId,
      'role': role,
    });

    if ((res['status'] as String?) == 'pending_approval') {
      return null;
    }

    final user = res['user'] as Map<String, dynamic>;
    int localId;
    if (kIsWeb) {
      localId = (user['email'] as String).hashCode & 0x7fffffff;
    } else {
      final db = await AppDb.instance;
      await db.insert(
        'users',
        LocalUser(
          email: user['email'] as String,
          orgId: user['orgId'] as String,
          role: user['role'] as String,
          isActive: (user['isActive'] ?? true) as bool,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final local = await db.query('users',
          where: 'email = ?', whereArgs: [user['email']], limit: 1);
      localId = local.first['id'] as int;
    }

    await sessionStore.saveSession(
      userId: localId,
      accessToken: res['accessToken'] as String,
      refreshToken: res['refreshToken'] as String,
      role: user['role'] as String?,
    );
    return localId;
  }

  Future<void> logout() => sessionStore.clear();
}
