import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_shell.dart';
import '../../state/admin_state.dart';
import '../../state/project_state.dart';
import '../../state/profile_state.dart';
import 'dashboard_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../sites/sites_screen.dart';
import '../tagging/tag_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _adminNotificationTimer;
  Timer? _autoRefreshTimer;
  late final List<Widget> _pages;

  static const _titles = ['Home', 'Tag', 'Location', 'Map', 'Profile'];

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(
        onAddVisitTap: () {
          setState(() => _index = 2);
          _refreshAll();
        },
      ),
      const TagScreen(),
      const SitesScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
    _adminNotificationTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      context.read<AdminState>().load();
    });
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      _refreshAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adminNotificationTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    context.read<ProjectState>().load();
    context.read<AdminState>().load();
    context.read<ProfileState>().load();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      index: _index,
      onTap: (value) {
        setState(() => _index = value);
        if (value == 0 || value == 2) {
          _refreshAll();
        }
      },
      title: _titles[_index],
      body: _pages[_index],
      topBanner: _buildApprovalBanner(),
    );
  }

  Widget _buildApprovalBanner() {
    final pending = context.watch<AdminState>().pendingCount;
    final hasPending = pending > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          hasPending
              ? Icons.notifications_active
              : Icons.notifications_none_outlined,
          size: 24,
          color: hasPending ? const Color(0xFF4FAE67) : const Color(0xFF6B7280),
        ),
        if (hasPending)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF4FAE67),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                pending.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
