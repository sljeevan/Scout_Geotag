import '../repositories/visit_repository.dart';

class VisitSyncService {
  VisitSyncService({required this.repository});

  final VisitRepository repository;

  Future<int> pendingCount() async {
    final rows = await repository.getPendingVisits();
    return rows.length;
  }
}
