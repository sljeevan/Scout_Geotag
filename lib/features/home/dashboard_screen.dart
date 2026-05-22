import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/status_mapper.dart';
import '../../core/widgets/app_card.dart';
import '../visits/repositories/visit_repository.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../sites/site_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onAddVisitTap,
  });

  final VoidCallback onAddVisitTap;

  @override
  Widget build(BuildContext context) {
    final projectState = context.watch<ProjectState>();
    final projects = projectState.projects;
    final active =
        projects.where((p) => normalizeStatus(p.status) == 'Active').length;
    final onHold =
        projects.where((p) => normalizeStatus(p.status) == 'On Hold').length;
    final completed =
        projects.where((p) => normalizeStatus(p.status) == 'Completed').length;
    final cancelled =
        projects.where((p) => normalizeStatus(p.status) == 'Cancelled').length;
    final projectCount = projects.length;
    final stakeholderCount = projectState.stakeholderCount;
    final partnerCount = projectState.partnerCount;
    final recent = [...projects]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.x3, AppSpacing.x2, AppSpacing.x3, AppSpacing.x1),
          child: Text('Overview',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text(
            '${projects.length} sites tracked',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          padding: const EdgeInsets.all(AppSpacing.x3),
          decoration: BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today\'s activity',
                  style: TextStyle(
                      color: Color(0x99FFFFFF),
                      fontWeight: FontWeight.w700,
                      fontSize: 11)),
              const SizedBox(height: 6),
              const Text('Welcome back',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.x2),
              Row(
                children: [
                  _heroStat('Project', projectCount.toString()),
                  _heroStat('Stake Holders', stakeholderCount.toString()),
                  _heroStat('Partners', partnerCount.toString()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.x2),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF8F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFAEDABD)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visited a project, stakeholder, or partner today?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onAddVisitTap,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Add Visit'),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Visited a project, stakeholder, or partner today?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onAddVisitTap,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Add Visit'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: FutureBuilder<int>(
            future: VisitRepository().getPendingVisits().then((v) => v.length),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return AppCard(
                child: Text(
                  'Pending visit sync/follow-ups: $count',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _tile('Active', active, AppColors.success),
              _tile('On Hold', onHold, AppColors.warning),
              _tile('Completed', completed, AppColors.info),
              _tile('Cancelled', cancelled, const Color(0xFF6B7280)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text('Recent Sites',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: AppSpacing.x1),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3),
            child: AppCard(child: Text('No sites yet')),
          ),
        ...recent.take(6).map(
              (p) => Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3, 0, AppSpacing.x3, AppSpacing.x1),
                child: AppCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => SiteDetailScreen(project: p)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.projectName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                          ),
                          _statusPill(normalizeStatus(p.status)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(p.developer ?? '-',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                        '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  static Widget _heroStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static Widget _tile(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value',
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static Widget _statusPill(String status) {
    Color fg;
    Color bg;
    switch (status) {
      case 'Active':
        fg = AppColors.success;
        bg = const Color(0xFFE8F5EE);
        break;
      case 'On Hold':
        fg = AppColors.warning;
        bg = const Color(0xFFEEF8F1);
        break;
      case 'Completed':
        fg = AppColors.info;
        bg = const Color(0xFFEAF0FD);
        break;
      default:
        fg = const Color(0xFF6B7280);
        bg = const Color(0xFFF3F4F6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 10)),
    );
  }
}
