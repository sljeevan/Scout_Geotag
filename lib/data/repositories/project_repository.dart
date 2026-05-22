import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../local/app_db.dart';
import '../models/project_models.dart';

class ProjectRepository {
  static const _pending = 'pending_upload';
  static const synced = 'synced';
  static const failedRetryable = 'failed_retryable';
  static const conflict = 'conflict';

  static const _kWebProjects = 'web_projects';
  static const _kWebQueue = 'web_sync_queue';
  static const _kWebProjectIdSeq = 'web_project_id_seq';
  static const _kWebQueueIdSeq = 'web_queue_id_seq';

  Future<List<Map<String, dynamic>>> _webReadList(String key) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _webWriteList(String key, List<Map<String, dynamic>> rows) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, jsonEncode(rows));
  }

  Future<int> _webNextId(String key) async {
    final p = await SharedPreferences.getInstance();
    final next = (p.getInt(key) ?? 0) + 1;
    await p.setInt(key, next);
    return next;
  }

  Future<void> _enqueueMutation({
    required String operation,
    required String entityId,
    required Project project,
  }) async {
    final payload = {
      'localId': project.id,
      'remoteId': project.remoteId,
      'userId': project.userId,
      'projectName': project.projectName,
      'developer': project.developer,
      'architect': project.architect,
      'pmc': project.pmc,
      'facadeConsultant': project.facadeConsultant,
      'segment': project.segment,
      'status': project.status,
      'outcome': project.outcome,
      'remarks': project.remarks,
      'latitude': project.latitude,
      'longitude': project.longitude,
      'updatedAt': project.updatedAt,
      'capturedAt': project.createdAt,
    };

    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      queue.add(SyncQueueItem(
        id: await _webNextId(_kWebQueueIdSeq),
        idempotencyKey: const Uuid().v4(),
        operation: operation,
        entityId: entityId,
        payloadJson: jsonEncode(payload),
        status: _pending,
      ).toMap());
      await _webWriteList(_kWebQueue, queue);
      return;
    }

    final db = await AppDb.instance;
    await db.insert(
        'sync_queue',
        SyncQueueItem(
          idempotencyKey: const Uuid().v4(),
          operation: operation,
          entityId: entityId,
          payloadJson: jsonEncode(payload),
          status: _pending,
        ).toMap());
  }

  Future<int> save(Project project) async {
    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      final id = await _webNextId(_kWebProjectIdSeq);
      final row = project.toMap()..['id'] = id;
      projects.add(row);
      await _webWriteList(_kWebProjects, projects);
      await _enqueueMutation(
        operation: 'create',
        entityId: id.toString(),
        project: Project.fromMap(row),
      );
      return id;
    }

    final db = await AppDb.instance;
    final id = await db.insert('projects', project.toMap());
    await _enqueueMutation(
      operation: 'create',
      entityId: id.toString(),
      project: Project(
        id: id,
        remoteId: project.remoteId,
        userId: project.userId,
        projectName: project.projectName,
        developer: project.developer,
        architect: project.architect,
        pmc: project.pmc,
        facadeConsultant: project.facadeConsultant,
        segment: project.segment,
        status: project.status,
        outcome: project.outcome,
        remarks: project.remarks,
        latitude: project.latitude,
        longitude: project.longitude,
        photoPath: project.photoPath,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      ),
    );

    return id;
  }

  Future<void> updateProject(Project project) async {
    if (project.id == null) {
      throw Exception('Project id is required for update');
    }

    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      final idx = projects.indexWhere((e) => e['id'] == project.id);
      if (idx == -1) throw Exception('Project not found');
      projects[idx] = project.toMap();
      await _webWriteList(_kWebProjects, projects);
      await _enqueueMutation(
        operation: 'update',
        entityId: project.remoteId ?? project.id.toString(),
        project: project,
      );
      return;
    }

    final db = await AppDb.instance;
    await db.update(
      'projects',
      project.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [project.id],
    );

    await _enqueueMutation(
      operation: 'update',
      entityId: project.remoteId ?? project.id.toString(),
      project: project,
    );
  }

  Future<void> deleteProject(Project project) async {
    if (project.id == null) {
      throw Exception('Project id is required for delete');
    }

    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      projects.removeWhere((e) => e['id'] == project.id);
      await _webWriteList(_kWebProjects, projects);
      await _enqueueMutation(
        operation: 'delete',
        entityId: project.remoteId ?? project.id.toString(),
        project: project,
      );
      return;
    }

    final db = await AppDb.instance;
    await db.delete('projects', where: 'id = ?', whereArgs: [project.id]);
    await _enqueueMutation(
      operation: 'delete',
      entityId: project.remoteId ?? project.id.toString(),
      project: project,
    );
  }

  Future<List<Project>> all(int userId) async {
    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      final rows = projects.where((e) => e['user_id'] == userId).toList()
        ..sort((a, b) => ((b['updated_at'] as int?) ?? 0)
            .compareTo((a['updated_at'] as int?) ?? 0));
      return rows.map(Project.fromMap).toList();
    }

    final db = await AppDb.instance;
    final rows = await db.query('projects',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'updated_at DESC');
    return rows.map(Project.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> pendingQueue() async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      final rows = queue
          .where((e) =>
              e['status'] == _pending || e['status'] == failedRetryable)
          .toList()
        ..sort((a, b) => ((a['id'] as int?) ?? 0).compareTo((b['id'] as int?) ?? 0));
      return rows;
    }

    final db = await AppDb.instance;
    return db.query(
      'sync_queue',
      where: 'status = ? OR status = ?',
      whereArgs: [_pending, failedRetryable],
      orderBy: 'id ASC',
    );
  }

  Future<void> markSynced(int queueId) async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      for (final row in queue) {
        if (row['id'] == queueId) row['status'] = synced;
      }
      await _webWriteList(_kWebQueue, queue);
      return;
    }

    final db = await AppDb.instance;
    await db.update('sync_queue', {'status': synced},
        where: 'id = ?', whereArgs: [queueId]);
  }

  Future<void> markRetryable(int queueId) async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      for (final row in queue) {
        if (row['id'] == queueId) row['status'] = failedRetryable;
      }
      await _webWriteList(_kWebQueue, queue);
      return;
    }

    final db = await AppDb.instance;
    await db.update('sync_queue', {'status': failedRetryable},
        where: 'id = ?', whereArgs: [queueId]);
  }

  Future<void> markConflict(int queueId) async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      for (final row in queue) {
        if (row['id'] == queueId) row['status'] = conflict;
      }
      await _webWriteList(_kWebQueue, queue);
      return;
    }

    final db = await AppDb.instance;
    await db.update('sync_queue', {'status': conflict},
        where: 'id = ?', whereArgs: [queueId]);
  }

  Future<int> conflictCount() async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      return queue.where((e) => e['status'] == conflict).length;
    }

    final db = await AppDb.instance;
    final res = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM sync_queue WHERE status = ?', [conflict]);
    return (res.first['c'] as int?) ?? 0;
  }

  Future<void> resolveAllConflictsAsPending() async {
    if (kIsWeb) {
      final queue = await _webReadList(_kWebQueue);
      for (final row in queue) {
        if (row['status'] == conflict) row['status'] = _pending;
      }
      await _webWriteList(_kWebQueue, queue);
      return;
    }

    final db = await AppDb.instance;
    await db.update('sync_queue', {'status': _pending},
        where: 'status = ?', whereArgs: [conflict]);
  }

  Future<void> upsertFromRemote({
    required String remoteId,
    required int userId,
    required String projectName,
    required String? developer,
    required String? architect,
    required String? pmc,
    required String? facadeConsultant,
    required String segment,
    required String status,
    required String? outcome,
    required String? remarks,
    required double latitude,
    required double longitude,
    String? photoPath,
    required int updatedAt,
  }) async {
    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      final idx = projects.indexWhere((e) => e['remote_id'] == remoteId);
      final createdAt = idx == -1
          ? updatedAt
          : ((projects[idx]['created_at'] as int?) ?? updatedAt);
      final map = {
        'id': idx == -1
            ? await _webNextId(_kWebProjectIdSeq)
            : projects[idx]['id'],
        'remote_id': remoteId,
        'user_id': userId,
        'project_name': projectName,
        'developer': developer,
        'architect': architect,
        'pmc': pmc,
        'facade_consultant': facadeConsultant,
        'segment': segment,
        'status': status,
        'outcome': outcome,
        'remarks': remarks,
        'latitude': latitude,
        'longitude': longitude,
        'photo_path': photoPath,
        'updated_at': updatedAt,
        'created_at': createdAt,
      };
      if (idx == -1) {
        projects.add(map);
      } else {
        projects[idx] = map;
      }
      await _webWriteList(_kWebProjects, projects);
      return;
    }

    final db = await AppDb.instance;
    final existing = await db.query('projects',
        where: 'remote_id = ?', whereArgs: [remoteId], limit: 1);
    final map = {
      'remote_id': remoteId,
      'user_id': userId,
      'project_name': projectName,
      'developer': developer,
      'architect': architect,
      'pmc': pmc,
      'facade_consultant': facadeConsultant,
      'segment': segment,
      'status': status,
      'outcome': outcome,
      'remarks': remarks,
      'latitude': latitude,
      'longitude': longitude,
      'photo_path': photoPath,
      'updated_at': updatedAt,
      'created_at':
          existing.isEmpty ? updatedAt : (existing.first['created_at'] as int),
    };
    if (existing.isEmpty) {
      await db.insert('projects', map);
    } else {
      await db.update('projects', map,
          where: 'id = ?', whereArgs: [existing.first['id']]);
    }
  }

  Future<void> deleteByRemoteId(String remoteId) async {
    if (kIsWeb) {
      final projects = await _webReadList(_kWebProjects);
      projects.removeWhere((e) => e['remote_id'] == remoteId);
      await _webWriteList(_kWebProjects, projects);
      return;
    }

    final db = await AppDb.instance;
    await db.delete('projects', where: 'remote_id = ?', whereArgs: [remoteId]);
  }
}
