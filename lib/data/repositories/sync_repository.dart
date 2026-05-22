import 'dart:convert';

import '../local/session_store.dart';
import '../remote/sitepin_api_client.dart';
import 'project_repository.dart';

class SyncRepository {
  final ProjectRepository projects;
  final SitePinApiClient api;
  final SessionStore sessionStore;

  SyncRepository(
      {required this.projects, required this.api, required this.sessionStore});

  Future<void> syncPending() async {
    final pending = await projects.pendingQueue();
    if (pending.isEmpty) {
      await pullAndApply();
      return;
    }

    final mutations = pending.map((row) {
      return {
        'idempotencyKey': row['idempotency_key'],
        'entityType': 'project',
        'entityId': row['entity_id'],
        'operation': row['operation'],
        'baseVersion': 1,
        'payload': jsonDecode(row['payload_json'] as String),
      };
    }).toList();

    try {
      final token = await _accessTokenEnsured();
      final res = await api.post('api/v1/sync/push', {'mutations': mutations},
          token: token);
      final results = (res['results'] as List).cast<Map<String, dynamic>>();

      for (var i = 0; i < results.length && i < pending.length; i++) {
        await projects.markSynced(pending[i]['id'] as int);
      }
    } on ApiException catch (e) {
      for (final row in pending) {
        if (e.statusCode == 409) {
          await projects.markConflict(row['id'] as int);
        } else {
          await projects.markRetryable(row['id'] as int);
        }
      }
      rethrow;
    }

    await pullAndApply();
  }

  Future<void> pullAndApply() async {
    final token = await _accessTokenEnsured();
    final userId = await sessionStore.currentUserId();
    if (userId == null) return;

    final sinceToken = await sessionStore.lastSyncToken();
    final res = await api.get(
      'api/v1/sync/pull',
      token: token,
      query: sinceToken == null ? null : {'sinceToken': sinceToken},
    );

    final changes = (res['changes'] as List).cast<Map<String, dynamic>>();
    for (final change in changes) {
      if (change['entityType'] != 'project') continue;
      if (change['operation'] == 'delete') {
        await projects.deleteByRemoteId(change['entityId'] as String);
        continue;
      }
      final data = change['data'] as Map<String, dynamic>;
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();
      if (latitude == null || longitude == null) continue;

      await projects.upsertFromRemote(
        remoteId: change['entityId'] as String,
        userId: userId,
        projectName: (data['projectName'] ?? '') as String,
        developer: data['developer'] as String?,
        architect: data['architect'] as String?,
        pmc: data['pmc'] as String?,
        facadeConsultant: data['facadeConsultant'] as String?,
        segment: (data['segment'] ?? '') as String,
        status: (data['status'] ?? 'Active') as String,
        outcome: data['outcome'] as String?,
        remarks: data['remarks'] as String?,
        latitude: latitude,
        longitude: longitude,
        photoPath: data['photoUrl'] as String?,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    final nextToken = (res['nextToken'] ?? '').toString();
    if (nextToken.isNotEmpty) {
      await sessionStore.setLastSyncToken(nextToken);
    }
  }

  Future<int> conflictCount() => projects.conflictCount();

  Future<void> retryConflicts() => projects.resolveAllConflictsAsPending();

  Future<String> _accessTokenEnsured() async {
    var token = await sessionStore.accessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No access token available');
    }

    try {
      await api.get('api/v1/health', token: token);
      return token;
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;
      final refresh = await sessionStore.refreshToken();
      if (refresh == null || refresh.isEmpty) rethrow;
      final refreshed =
          await api.post('api/v1/auth/refresh', {'refreshToken': refresh});
      await sessionStore.saveTokens(
        accessToken: refreshed['accessToken'] as String,
        refreshToken: refreshed['refreshToken'] as String,
      );
      token = refreshed['accessToken'] as String;
      return token;
    }
  }
}
