import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/session_store.dart';
import '../models/visit_model.dart';
import '../repositories/visit_repository.dart';

class VisitProvider extends ChangeNotifier {
  VisitProvider({required this.repo, required this.sessionStore});

  final VisitRepository repo;
  final SessionStore sessionStore;

  List<VisitModel> _visits = [];
  bool _loading = false;
  String? _error;

  List<VisitModel> get visits => _visits;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadByProject(String projectId) async {
    _loading = true;
    notifyListeners();
    try {
      _visits = await repo.getVisitsByProject(projectId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addVisit({
    required String projectId,
    required String visitType,
    required int visitDate,
    String? startTime,
    String? endTime,
    String? clientName,
    String? partnerName,
    String? attendees,
    String? discussionPoints,
    String? decisionsTaken,
    String? actionItems,
    String? outcomeStatus,
    double? latitude,
    double? longitude,
  }) async {
    final userId = await sessionStore.currentUserId() ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final visit = VisitModel(
      id: const Uuid().v4(),
      projectId: projectId,
      userId: userId,
      visitType: visitType,
      visitDate: visitDate,
      startTime: startTime,
      endTime: endTime,
      clientName: clientName,
      partnerName: partnerName,
      attendees: attendees,
      discussionPoints: discussionPoints,
      decisionsTaken: decisionsTaken,
      actionItems: actionItems,
      outcomeStatus: outcomeStatus,
      latitude: latitude,
      longitude: longitude,
      syncStatus: VisitSyncStatus.pendingUpload,
      createdAt: now,
      updatedAt: now,
    );
    await repo.insertVisit(visit);
    await loadByProject(projectId);
  }
}
