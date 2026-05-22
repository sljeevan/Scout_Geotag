import 'dart:io';

import 'package:flutter/foundation.dart';
import '../data/local/session_store.dart';
import '../data/models/project_models.dart';
import '../data/models/tag_entry.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/sync_repository.dart';
import '../data/repositories/tag_repository.dart';

class ProjectState extends ChangeNotifier {
  final ProjectRepository projectRepo;
  final SyncRepository syncRepo;
  final SessionStore sessionStore;
  final TagRepository tagRepo;

  ProjectState(
      {required this.projectRepo,
      required this.syncRepo,
      required this.sessionStore,
      required this.tagRepo});

  List<Project> _projects = [];
  bool _saving = false;
  String? _error;
  int _conflictCount = 0;
  int _stakeholderCount = 0;
  int _partnerCount = 0;
  List<TagEntry> _latestTags = [];

  List<Project> get projects => _projects;
  bool get saving => _saving;
  String? get error => _error;
  int get conflictCount => _conflictCount;
  int get stakeholderCount => _stakeholderCount;
  int get partnerCount => _partnerCount;
  List<TagEntry> get latestTags => _latestTags;

  Future<void> load() async {
    final userId = await sessionStore.currentUserId();
    if (userId == null) return;
    try {
      await syncRepo.pullAndApply();
    } catch (_) {
      // Keep showing cached/local data if pull fails.
    }
    _projects = await projectRepo.all(userId);
    _conflictCount = await syncRepo.conflictCount();
    _latestTags = await tagRepo.allTagEntries();
    _stakeholderCount = await tagRepo.stakeholderCount();
    _partnerCount = await tagRepo.partnerCount();
    notifyListeners();
  }

  Future<void> saveTagEntry(TagEntry entry) async {
    _saving = true;
    notifyListeners();
    try {
      await tagRepo.saveTagEntry(entry);
      _latestTags = await tagRepo.allTagEntries();
      _stakeholderCount = await tagRepo.stakeholderCount();
      _partnerCount = await tagRepo.partnerCount();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateTagEntry(TagEntry entry) async {
    _saving = true;
    notifyListeners();
    try {
      await tagRepo.updateTagEntry(entry);
      _latestTags = await tagRepo.allTagEntries();
      _stakeholderCount = await tagRepo.stakeholderCount();
      _partnerCount = await tagRepo.partnerCount();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> saveGeotag({
    required String projectName,
    String? developer,
    String? architect,
    String? pmc,
    String? facadeConsultant,
    required String segment,
    required String status,
    String? outcome,
    String? remarks,
    required double latitude,
    required double longitude,
    File? photo,
  }) async {
    final userId = await sessionStore.currentUserId();
    if (userId == null) return;

    _saving = true;
    notifyListeners();

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await projectRepo.save(
        Project(
          userId: userId,
          projectName: projectName,
          developer: developer,
          architect: architect,
          pmc: pmc,
          facadeConsultant: facadeConsultant,
          segment: segment,
          status: status,
          outcome: outcome,
          remarks: remarks,
          latitude: latitude,
          longitude: longitude,
          photoPath: photo?.path,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await syncRepo.syncPending();
      await load();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    _saving = true;
    notifyListeners();
    try {
      await projectRepo.updateProject(project);
      await syncRepo.syncPending();
      await load();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> syncNow() async {
    try {
      await syncRepo.syncPending();
      await load();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> retryConflicts() async {
    await syncRepo.retryConflicts();
    await syncNow();
  }

  Future<void> deleteProject(Project project) async {
    _saving = true;
    notifyListeners();
    try {
      await projectRepo.deleteProject(project);
      await syncRepo.syncPending();
      await load();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
