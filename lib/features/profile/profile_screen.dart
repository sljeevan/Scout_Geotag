import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_profile.dart';
import '../../state/auth_state.dart';
import '../../state/profile_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileState>();
    final profile = state.profile;

    if (state.loading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load profile'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<ProfileState>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileState>().load(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.x3),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.x3, AppSpacing.x2, AppSpacing.x3, AppSpacing.x1),
            child: Text('Profile',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          ),
          _profileHeader(
            context: context,
            profile: profile,
            onEditAvatar: () => _pickAndUploadAvatar(context, profile),
          ),
          const SizedBox(height: AppSpacing.x2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
            child: _editProfileButton(
              context,
              onTap: () => _openEditDialog(context, profile),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          _infoSection(
            context,
            profile,
            onEdit: () => _openEditDialog(context, profile),
          ),
          const SizedBox(height: AppSpacing.x2),
          _actionCard(
            icon: Icons.tune,
            iconBg: const Color(0xFFEAF8F1),
            iconColor: AppColors.success,
            title: 'Preferences',
            subtitle: 'Manage app preferences and notifications',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: AppSpacing.x1),
          _actionCard(
            icon: Icons.shield_outlined,
            iconBg: const Color(0xFFEAF0FD),
            iconColor: AppColors.info,
            title: 'Security',
            subtitle: 'Change password and account security',
            onTap: () => _openSecurityDialog(context),
          ),
          const SizedBox(height: AppSpacing.x1),
          _actionCard(
            icon: Icons.logout,
            iconBg: const Color(0xFFFFECEC),
            iconColor: AppColors.danger,
            title: 'Log Out',
            subtitle: 'Sign out from your account',
            titleColor: AppColors.danger,
            onTap: () => context.read<AuthState>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader({
    required BuildContext context,
    required UserProfile profile,
    required VoidCallback onEditAvatar,
  }) {
    final initials =
        _initials(profile.fullName.isEmpty ? profile.email : profile.fullName);
    final avatarUrl = _validatedAvatarUrl(profile.avatarUrl);
    final hasAvatar = avatarUrl != null;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFE9F8ED),
                  backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  child: !hasAvatar
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandStrong,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: -2,
              child: InkWell(
                onTap: onEditAvatar,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          profile.fullName.isEmpty ? 'Scout User' : profile.fullName,
          style: const TextStyle(fontSize: 46 / 2, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          _valueOrFallback(profile.designation, 'Associate Consultant'),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apartment_outlined, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              _valueOrFallback(profile.company, 'HCL Technologies'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _editProfileButton(BuildContext context,
      {required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F8ED),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: AppColors.brand),
            SizedBox(width: 10),
            Text(
              'Edit Profile',
              style: TextStyle(
                color: AppColors.brand,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(
    BuildContext context,
    UserProfile profile, {
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          _infoRow(Icons.mail_outline, const Color(0xFFE9F8ED), AppColors.brand,
              'Email', profile.email),
          _divider(),
          _infoRow(Icons.call_outlined, const Color(0xFFEAF8F1),
              AppColors.success, 'Phone', _valueOrFallback(profile.phone, '-')),
          _divider(),
          _infoRow(
              Icons.apartment_outlined,
              const Color(0xFFEAF0FD),
              AppColors.info,
              'Company',
              _valueOrFallback(profile.company, '-')),
          _divider(),
          _infoRow(
              Icons.work_outline,
              const Color(0xFFF1ECFF),
              const Color(0xFF7E58C2),
              'Role',
              _valueOrFallback(profile.designation, profile.role)),
          _divider(),
          _infoRow(
              Icons.badge_outlined,
              const Color(0xFFF1FAEE),
              AppColors.warning,
              'Employee ID',
              _valueOrFallback(profile.employeeId, '-')),
          _divider(),
          _infoRow(
              Icons.location_on_outlined,
              const Color(0xFFFFECEC),
              const Color(0xFFD94A4A),
              'Location',
              _valueOrFallback(profile.location, '-')),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    Color bg,
    Color fg,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: const Color(0xFFF0F0F0));

  Widget _actionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppColors.textPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
        padding: const EdgeInsets.all(AppSpacing.x2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditDialog(
      BuildContext context, UserProfile profile) async {
    final name = TextEditingController(text: profile.fullName);
    final phone = TextEditingController(text: profile.phone ?? '');
    final company = TextEditingController(text: profile.company ?? '');
    final designation = TextEditingController(text: profile.designation ?? '');
    final employeeId = TextEditingController(text: profile.employeeId ?? '');
    final location = TextEditingController(text: profile.location ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.x3,
            right: AppSpacing.x3,
            top: AppSpacing.x3,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.x3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.x2),
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: AppSpacing.x1),
              TextField(
                  controller: designation,
                  decoration: const InputDecoration(labelText: 'Designation')),
              const SizedBox(height: AppSpacing.x1),
              TextField(
                  controller: company,
                  decoration: const InputDecoration(labelText: 'Company')),
              const SizedBox(height: AppSpacing.x1),
              TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: AppSpacing.x1),
              TextField(
                  controller: employeeId,
                  decoration: const InputDecoration(labelText: 'Employee ID')),
              const SizedBox(height: AppSpacing.x1),
              TextField(
                  controller: location,
                  decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: AppSpacing.x2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('SAVE'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (saved != true || !context.mounted) return;

    final next = profile.copyWith(
      fullName: name.text.trim().isEmpty ? profile.fullName : name.text.trim(),
      phone: _nullIfEmpty(phone.text),
      company: _nullIfEmpty(company.text),
      designation: _nullIfEmpty(designation.text),
      employeeId: _nullIfEmpty(employeeId.text),
      location: _nullIfEmpty(location.text),
    );

    try {
      await context.read<ProfileState>().save(next);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save profile. Please retry.')),
      );
    }
  }

  Future<void> _openSecurityDialog(BuildContext context) async {
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? formError;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.x3,
                right: AppSpacing.x3,
                top: AppSpacing.x3,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.x3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Security',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Change account password',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextField(
                    controller: currentPassword,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setLocal(() => obscureCurrent = !obscureCurrent),
                        icon: Icon(obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  TextField(
                    controller: newPassword,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      helperText: 'Minimum 8 characters',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setLocal(() => obscureNew = !obscureNew),
                        icon: Icon(obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  TextField(
                    controller: confirmPassword,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setLocal(() => obscureConfirm = !obscureConfirm),
                        icon: Icon(obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                  ),
                  if (formError != null) ...[
                    const SizedBox(height: AppSpacing.x1),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formError!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final current = currentPassword.text.trim();
                        final next = newPassword.text.trim();
                        final confirm = confirmPassword.text.trim();
                        if (current.isEmpty ||
                            next.isEmpty ||
                            confirm.isEmpty) {
                          setLocal(() =>
                              formError = 'All password fields are required.');
                          return;
                        }
                        if (next.length < 8) {
                          setLocal(() => formError =
                              'New password must be at least 8 characters.');
                          return;
                        }
                        if (next != confirm) {
                          setLocal(() => formError =
                              'New password and confirmation do not match.');
                          return;
                        }
                        if (current == next) {
                          setLocal(() => formError =
                              'New password must be different from current password.');
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('UPDATE PASSWORD'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (submitted != true || !context.mounted) return;
    try {
      await context.read<ProfileState>().changePassword(
            currentPassword: currentPassword.text.trim(),
            newPassword: newPassword.text.trim(),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update password: $e')),
      );
    }
  }

  Future<void> _pickAndUploadAvatar(
      BuildContext context, UserProfile profile) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null || !context.mounted) return;
    try {
      final bytes = await picked.readAsBytes();
      final b64 = base64Encode(bytes);
      await context.read<ProfileState>().saveWithAvatar(profile, b64);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to upload image: $e')),
      );
    }
  }

  static void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section will be available soon.')),
    );
  }

  static String _valueOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
  }

  static String? _nullIfEmpty(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  static String _initials(String text) {
    final parts =
        text.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static String? _validatedAvatarUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return value;
    }
    return null;
  }
}
