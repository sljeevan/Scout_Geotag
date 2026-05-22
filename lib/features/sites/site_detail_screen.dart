import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/status_mapper.dart';
import '../../core/widgets/app_button.dart';
import '../../data/local/session_store.dart';
import '../../data/models/project_models.dart';
import '../../state/auth_state.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../visits/models/visit_model.dart';
import '../visits/providers/visit_provider.dart';
import '../visits/repositories/visit_repository.dart';
import '../visits/widgets/visit_list_item.dart';
import 'project_edit_screen.dart';

class SiteDetailScreen extends StatelessWidget {
  const SiteDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final projectId = project.remoteId ?? project.id?.toString() ?? '';
    return ChangeNotifierProvider(
      create: (_) => VisitProvider(
        repo: VisitRepository(),
        sessionStore: SessionStore(),
      )..loadByProject(projectId),
      child: _ProjectDetailBody(project: project, projectId: projectId),
    );
  }
}

class _ProjectDetailBody extends StatelessWidget {
  const _ProjectDetailBody({required this.project, required this.projectId});

  final Project project;
  final String projectId;

  Future<void> _showAddVisitSheet(BuildContext context) async {
    final discussionCtrl = TextEditingController();
    final nextActionCtrl = TextEditingController();
    final capturedAt = DateTime.now();
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> submit() async {
              final discussion = discussionCtrl.text.trim();
              if (discussion.isEmpty) {
                setSheetState(() => error = 'Discussion point is required');
                return;
              }
              await context.read<VisitProvider>().addVisit(
                    projectId: projectId,
                    visitType: VisitTypes.siteInspection,
                    visitDate: capturedAt.millisecondsSinceEpoch,
                    startTime:
                        '${capturedAt.hour.toString().padLeft(2, '0')}:${capturedAt.minute.toString().padLeft(2, '0')}',
                    discussionPoints: discussion,
                    actionItems: nextActionCtrl.text.trim().isEmpty
                        ? null
                        : nextActionCtrl.text.trim(),
                    outcomeStatus: VisitOutcomeStatus.pendingClarification,
                  );
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
            }

            final inset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.x3,
                AppSpacing.x3,
                AppSpacing.x3,
                inset + AppSpacing.x3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log Visit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'Captured at: ${capturedAt.toLocal()}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextFormField(
                    controller: discussionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Discussion Points',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextFormField(
                    controller: nextActionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Next Action (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: AppSpacing.x2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: submit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('SAVE VISIT'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = normalizeStatus(project.status);
    final isAdmin = (context.watch<AuthState>().role ?? '').toLowerCase() == 'admin';
    final visitState = context.watch<VisitProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Location Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x3),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.x2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9FD8B1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    project.projectName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                _pill('Project'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _openDirections(context, project.latitude, project.longitude),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('DIRECTIONS'),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          _infoCard('Type', 'Project'),
          _infoCard('Status', status),
          _infoCard('Segment', project.segment),
          if ((project.developer ?? '').isNotEmpty) _infoCard('Developer', project.developer!),
          if ((project.architect ?? '').isNotEmpty) _infoCard('Architect', project.architect!),
          if ((project.pmc ?? '').isNotEmpty) _infoCard('PMC', project.pmc!),
          if ((project.facadeConsultant ?? '').isNotEmpty) _infoCard('Facade Consultant', project.facadeConsultant!),
          _infoCard('Coordinates', '${project.latitude.toStringAsFixed(5)}, ${project.longitude.toStringAsFixed(5)}'),
          if ((project.remarks ?? '').isNotEmpty) _infoCard('Notes', project.remarks!),
          _infoCard('Updated', DateTime.fromMillisecondsSinceEpoch(project.updatedAt).toLocal().toString()),
          if (project.photoPath != null && project.photoPath!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.x2),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(File(project.photoPath!), height: 210, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: AppSpacing.x1),
          Row(
            children: [
              const Text('Visit Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddVisitSheet(context),
                icon: const Icon(Icons.add_outlined),
                label: const Text('Add Visit'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          if (visitState.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x2),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visitState.visits.isEmpty)
            _infoCard('Visits', 'No visits logged yet.')
          else
            ...visitState.visits.map((v) => VisitListItem(visit: v)),
          const SizedBox(height: AppSpacing.x2),
          AppButton(
            label: 'EDIT',
            icon: Icons.edit_outlined,
            onPressed: () => _showEditDialog(context),
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpacing.x1),
            AppButton(
              label: 'DELETE',
              icon: Icons.delete_outline,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete site?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                        ],
                      ),
                    ) ??
                    false;
                if (!confirm || !context.mounted) return;
                await context.read<ProjectState>().deleteProject(project);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final updated = await Navigator.of(context).push<Project>(
      MaterialPageRoute(builder: (_) => ProjectEditScreen(project: project)),
    );
    if (updated == null || !context.mounted) return;
    await context.read<ProjectState>().updateProject(updated);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Widget _pill(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(999)),
      child: const Text(
        'Project',
        style: TextStyle(color: AppColors.brandStrong, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x1),
      padding: const EdgeInsets.all(AppSpacing.x2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _openDirections(BuildContext context, double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions')),
      );
    }
  }
}
