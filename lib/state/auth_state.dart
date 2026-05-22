import 'package:flutter/foundation.dart';
import '../data/local/session_store.dart';
import '../data/repositories/auth_repository.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository authRepo;
  final SessionStore sessionStore;

  AuthState({required this.authRepo, required this.sessionStore});

  bool _loading = false;
  bool _loggedIn = false;
  String? _error;
  String? _notice;
  String? _role;

  bool get loading => _loading;
  bool get loggedIn => _loggedIn;
  String? get error => _error;
  String? get notice => _notice;
  String? get role => _role;

  Future<void> bootstrap() async {
    _loggedIn = await sessionStore.isLoggedIn();
    _role = await sessionStore.currentUserRole();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await authRepo.login(
          email: email, password: password, deviceId: 'flutter-device');
      _loggedIn = true;
      _role = await sessionStore.currentUserRole();
      _error = null;
      _notice = null;
    } catch (e) {
      _error = e.toString();
      _notice = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(
      String email, String password, String orgId, String role) async {
    _setLoading(true);
    try {
      final localUserId = await authRepo.register(
          email: email, password: password, orgId: orgId, role: role);
      _loggedIn = localUserId != null;
      _role = localUserId != null ? await sessionStore.currentUserRole() : null;
      _error = null;
      _notice = localUserId == null
          ? 'Registration submitted. Account is pending admin approval.'
          : 'Registration successful.';
    } catch (e) {
      _error = e.toString();
      _notice = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await authRepo.logout();
    _loggedIn = false;
    _role = null;
    _notice = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
