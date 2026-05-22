import 'package:flutter/foundation.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/profile_repository.dart';

class ProfileState extends ChangeNotifier {
  ProfileState({required this.profileRepo});

  final ProfileRepository profileRepo;

  bool _loading = false;
  String? _error;
  UserProfile? _profile;

  bool get loading => _loading;
  String? get error => _error;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    _setLoading(true);
    try {
      _profile = await profileRepo.fetchProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> save(UserProfile profile) async {
    _setLoading(true);
    try {
      _profile = await profileRepo.updateProfile(profile) ?? profile;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveWithAvatar(UserProfile profile, String avatarBase64) async {
    _setLoading(true);
    try {
      _profile = await profileRepo.updateProfileWithAvatar(
            profile: profile,
            avatarBase64: avatarBase64,
          ) ??
          profile;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await profileRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
