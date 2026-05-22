import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/app_db.dart';
import '../models/visit_model.dart';

class VisitRepository {
  static const _kWebVisits = 'web_visits';

  Future<List<Map<String, dynamic>>> _webRead() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kWebVisits);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _webWrite(List<Map<String, dynamic>> rows) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kWebVisits, jsonEncode(rows));
  }

  Future<void> insertVisit(VisitModel visit) async {
    if (kIsWeb) {
      final rows = await _webRead();
      rows.removeWhere((e) => e['id'] == visit.id);
      rows.add(visit.toJson());
      await _webWrite(rows);
      return;
    }
    final db = await AppDb.instance;
    await db.insert('visits', visit.toJson());
  }

  Future<void> updateVisit(VisitModel visit) async {
    if (kIsWeb) {
      final rows = await _webRead();
      final idx = rows.indexWhere((e) => e['id'] == visit.id);
      if (idx >= 0) {
        rows[idx] = visit.toJson();
        await _webWrite(rows);
      }
      return;
    }
    final db = await AppDb.instance;
    await db.update(
      'visits',
      visit.toJson(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  Future<List<VisitModel>> getVisitsByProject(String projectId) async {
    if (kIsWeb) {
      final rows = await _webRead();
      final filtered = rows.where((e) => (e['project_id'] ?? '').toString() == projectId).toList()
        ..sort((a, b) => ((b['visit_date'] ?? 0) as int).compareTo((a['visit_date'] ?? 0) as int));
      return filtered.map(VisitModel.fromJson).toList();
    }

    final db = await AppDb.instance;
    final rows = await db.query(
      'visits',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'visit_date DESC, created_at DESC',
    );
    return rows.map(VisitModel.fromJson).toList();
  }

  Future<List<VisitModel>> getPendingVisits() async {
    if (kIsWeb) {
      final rows = await _webRead();
      final filtered = rows
          .where((e) => (e['sync_status'] ?? '') == VisitSyncStatus.pendingUpload)
          .toList();
      return filtered.map(VisitModel.fromJson).toList();
    }

    final db = await AppDb.instance;
    final rows = await db.query(
      'visits',
      where: 'sync_status = ?',
      whereArgs: [VisitSyncStatus.pendingUpload],
      orderBy: 'created_at ASC',
    );
    return rows.map(VisitModel.fromJson).toList();
  }

  Future<void> markVisitSynced(String id) async {
    if (kIsWeb) {
      final rows = await _webRead();
      final idx = rows.indexWhere((e) => e['id'] == id);
      if (idx >= 0) {
        rows[idx]['sync_status'] = VisitSyncStatus.synced;
        await _webWrite(rows);
      }
      return;
    }

    final db = await AppDb.instance;
    await db.update(
      'visits',
      {'sync_status': VisitSyncStatus.synced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
