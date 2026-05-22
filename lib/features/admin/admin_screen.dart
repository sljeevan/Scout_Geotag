import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../state/admin_state.dart';
import '../../theme/app_spacing.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<AdminState>().load());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    if (state.loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x2),
      children: [
        if (state.pendingCount > 0)
          AppCard(
            child: Text(
              '${state.pendingCount} user(s) pending approval',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        if (state.pendingCount > 0) const SizedBox(height: AppSpacing.x2),
        ...state.users.map((u) {
          final active = (u['isActive'] as bool?) ?? false;
          final role = (u['role'] as String?) ?? 'user';
          final requestedRole = (u['requestedRole'] as String?) ?? role;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x2),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u['email'] as String,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.x1),
                  Text('Current Role: $role'),
                  Text('Requested Role: $requestedRole'),
                  Text('Status: ${active ? 'Approved' : 'Pending'}'),
                  if (!active) ...[
                    const SizedBox(height: AppSpacing.x2),
                    AppButton(
                      label: requestedRole == 'admin'
                          ? 'Approve as Admin'
                          : 'Approve User',
                      icon: Icons.verified_user_outlined,
                      onPressed: () =>
                          context.read<AdminState>().approve(u['id'] as String),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
