import '../local/session_store.dart';
import '../models/user_profile.dart';
import '../remote/sitepin_api_client.dart';

class ProfileRepository {
  ProfileRepository({required this.api, required this.sessionStore});

  final SitePinApiClient api;
  final SessionStore sessionStore;

  Future<UserProfile?> fetchProfile() async {
    final token = await sessionStore.accessToken();
    if (token == null) return null;
    final res = await api.get('api/v1/profile', token: token);
    final raw = res['profile'] as Map<String, dynamic>?;
    if (raw == null) return null;
    return UserProfile.fromJson(raw);
  }

  Future<UserProfile?> updateProfile(UserProfile profile) async {
    return updateProfileWithAvatar(profile: profile);
  }

  Future<UserProfile?> updateProfileWithAvatar({
    required UserProfile profile,
    String? avatarBase64,
  }) async {
    final token = await sessionStore.accessToken();
    if (token == null) return null;
    final res = await api.put(
      'api/v1/profile',
      {
        ...profile.toUpdatePayload(),
        if (avatarBase64 != null && avatarBase64.isNotEmpty) 'avatarBase64': avatarBase64,
      },
      token: token,
    );
    final raw = res['profile'] as Map<String, dynamic>?;
    if (raw == null) return null;
    return UserProfile.fromJson(raw);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await sessionStore.accessToken();
    if (token == null) return;
    await api.post(
      'api/v1/auth/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      token: token,
    );
  }
}
