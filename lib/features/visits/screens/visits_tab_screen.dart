import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_spacing.dart';
import '../providers/visit_provider.dart';
import '../widgets/visit_list_item.dart';

class VisitsTabScreen extends StatefulWidget {
  const VisitsTabScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<VisitsTabScreen> createState() => _VisitsTabScreenState();
}

class _VisitsTabScreenState extends State<VisitsTabScreen> {
  Future<void> _showAddVisitSheet() async {
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
                    projectId: widget.projectId,
                    visitType: 'Site Inspection',
                    visitDate: capturedAt.millisecondsSinceEpoch,
                    startTime:
                        '${capturedAt.hour.toString().padLeft(2, '0')}:${capturedAt.minute.toString().padLeft(2, '0')}',
                    discussionPoints: discussion,
                    actionItems: nextActionCtrl.text.trim().isEmpty
                        ? null
                        : nextActionCtrl.text.trim(),
                    outcomeStatus: 'Pending Clarification',
                  );
              if (!mounted) return;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().loadByProject(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisitProvider>();
    final visits = state.visits;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.x2, AppSpacing.x2, AppSpacing.x2, 0),
          child: Row(
            children: [
              const Text('Visits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  await _showAddVisitSheet();
                  if (!context.mounted) return;
                  await context
                      .read<VisitProvider>()
                      .loadByProject(widget.projectId);
                },
                icon: const Icon(Icons.add_outlined),
                label: const Text('Add Visit'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.loading
              ? const Center(child: CircularProgressIndicator())
              : visits.isEmpty
                  ? const Center(child: Text('No visits yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.x2),
                      itemCount: visits.length,
                      itemBuilder: (_, i) {
                        final visit = visits[i];
                        final date = DateTime.fromMillisecondsSinceEpoch(visit.visitDate).toLocal();
                        final showDateHeader = i == 0 ||
                            DateTime.fromMillisecondsSinceEpoch(visits[i - 1].visitDate).toLocal().day != date.day ||
                            DateTime.fromMillisecondsSinceEpoch(visits[i - 1].visitDate).toLocal().month != date.month ||
                            DateTime.fromMillisecondsSinceEpoch(visits[i - 1].visitDate).toLocal().year != date.year;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 6),
                                child: Text(
                                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            VisitListItem(visit: visit),
                          ],
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
