import '../local/session_store.dart';
import '../remote/sitepin_api_client.dart';

class AdminRepository {
  final SitePinApiClient api;
  final SessionStore sessionStore;

  AdminRepository({required this.api, required this.sessionStore});

  Future<List<Map<String, dynamic>>> listUsers() async {
    final token = await sessionStore.accessToken();
    if (token == null) return [];
    final res = await api.get('api/v1/users', token: token);
    return (res['users'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> approve(String userId) async {
    final token = await sessionStore.accessToken();
    if (token == null) return;
    await api.post('api/v1/users/$userId/approve', {}, token: token);
  }
}
