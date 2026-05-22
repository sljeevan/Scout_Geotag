import 'package:flutter/foundation.dart';
import '../data/repositories/admin_repository.dart';

class AdminState extends ChangeNotifier {
  final AdminRepository adminRepo;

  AdminState({required this.adminRepo});

  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  List<Map<String, dynamic>> get users => _users;
  bool get loading => _loading;
  int get pendingCount => _users.where((u) => (u['isActive'] as bool?) != true).length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await adminRepo.listUsers();
    } catch (_) {
      _users = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> approve(String userId) async {
    await adminRepo.approve(userId);
    await load();
  }
}
