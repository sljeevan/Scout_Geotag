import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/project_models.dart';
import '../../state/project_state.dart';
import '../../theme/app_spacing.dart';
import '../sites/project_edit_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  Future<void> _editProject(Project p) async {
    final updated = await Navigator.of(context).push<Project>(
      MaterialPageRoute(builder: (_) => ProjectEditScreen(project: p)),
    );
    if (updated == null || !mounted) return;
    await context.read<ProjectState>().updateProject(updated);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProjectState>();
    final projects = state.projects;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2, AppSpacing.x2, AppSpacing.x2, AppSpacing.x1),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Sync Now',
                  icon: Icons.sync,
                  onPressed: () => context.read<ProjectState>().syncNow(),
                ),
              ),
            ],
          ),
        ),
        if (state.conflictCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2, 0, AppSpacing.x2, AppSpacing.x2),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sync conflicts: ${state.conflictCount}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.x1),
                  AppButton(
                    label: 'Retry Conflicts',
                    icon: Icons.refresh,
                    onPressed: () =>
                        context.read<ProjectState>().retryConflicts(),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: projects.isEmpty
              ? const Center(child: Text('No projects yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.x2),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.x2),
                  itemBuilder: (_, i) {
                    final p = projects[i];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.projectName,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.x1),
                          Text('Segment: ${p.segment}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                              'Status: ${p.status}${p.outcome == null ? '' : ' • ${p.outcome}'}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          if (p.remarks != null && p.remarks!.isNotEmpty)
                            Text('Remarks: ${p.remarks}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          Text('Coordinates: ${p.latitude}, ${p.longitude}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSpacing.x2),
                          AppButton(
                            label: 'Edit',
                            icon: Icons.edit_outlined,
                            onPressed: () => _editProject(p),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
