import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/tag_entry.dart';
import '../../data/models/visit_entry.dart';
import '../../data/repositories/tag_repository.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../tagging/config/tag_constants.dart';
import 'tag_edit_screen.dart';

class TagDetailScreen extends StatefulWidget {
  const TagDetailScreen({super.key, required this.tag});

  final TagEntry tag;

  @override
  State<TagDetailScreen> createState() => _TagDetailScreenState();
}

class _TagDetailScreenState extends State<TagDetailScreen> {
  List<VisitEntry> _visits = const [];
  bool _loadingVisits = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final tagId = widget.tag.id;
    if (tagId == null || tagId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _visits = const [];
        _loadingVisits = false;
      });
      return;
    }

    final repo = context.read<ProjectState>().tagRepo;
    try {
      final rows = await repo.listVisits(tagId: tagId);
      if (!mounted) return;
      setState(() {
        _visits = rows;
        _loadingVisits = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingVisits = false);
    }
  }

  Future<void> _showAddVisitSheet(TagRepository repo) async {
    final tagId = widget.tag.id;
    if (tagId == null || tagId.isEmpty) return;
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
              await repo.createVisit(
                tagId: tagId,
                visitDate: capturedAt.millisecondsSinceEpoch,
                discussionPoints: discussion,
                nextAction: nextActionCtrl.text.trim().isEmpty ? null : nextActionCtrl.text.trim(),
              );
              if (!mounted) return;
              Navigator.of(ctx).pop();
              await _loadVisits();
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

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _visitDateTime(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs).toLocal();
    return '${_dateOnly(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.tag;
    final colors = _typeColors(tag.tagType);
    final repo = context.read<ProjectState>().tagRepo;

    return Scaffold(
      appBar: AppBar(title: const Text('Location Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x3),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.x2),
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tag.entityName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                _pill(tag.tagType, colors),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _openDirections(context, tag.latitude, tag.longitude),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('DIRECTIONS'),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          _infoCard('Type', tag.tagType == TagTypes.stakeholder ? 'Stake holder' : tag.tagType),
          _infoCard('Category', tag.category),
          if ((tag.contactPerson ?? '').isNotEmpty) _infoCard('Contact Person', tag.contactPerson!),
          if ((tag.phone ?? '').isNotEmpty) _infoCard('Phone', tag.phone!),
          if ((tag.email ?? '').isNotEmpty) _infoCard('Email', tag.email!),
          if ((tag.address ?? '').isNotEmpty) _infoCard('Address', tag.address!),
          _infoCard('Coordinates', '${tag.latitude.toStringAsFixed(5)}, ${tag.longitude.toStringAsFixed(5)}'),
          _infoCard(
            'Captured At',
            DateTime.fromMillisecondsSinceEpoch(tag.capturedAt).toLocal().toString(),
          ),
          const SizedBox(height: AppSpacing.x1),
          Row(
            children: [
              const Text(
                'Visit Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddVisitSheet(repo),
                icon: const Icon(Icons.add_outlined),
                label: const Text('Add Visit'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          if (_loadingVisits)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x2),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_visits.isEmpty)
            _infoCard('Visits', 'No visits logged yet.')
          else
            ..._visits.map(
              (visit) => _visitCard(visit),
            ),
          const SizedBox(height: AppSpacing.x1),
          ElevatedButton.icon(
            onPressed: () async {
              final updated = await Navigator.of(context).push<TagEntry>(
                MaterialPageRoute(builder: (_) => TagEditScreen(tag: tag)),
              );
              if (updated == null || !context.mounted) return;
              await context.read<ProjectState>().updateTagEntry(updated);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('EDIT'),
          ),
        ],
      ),
    );
  }

  Widget _visitCard(VisitEntry visit) {
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
            _visitDateTime(visit.visitDate),
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(visit.discussionPoints, style: const TextStyle(fontWeight: FontWeight.w600)),
          if ((visit.nextAction ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Next: ${visit.nextAction}', style: const TextStyle(color: AppColors.textMuted)),
          ],
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

  Widget _pill(String type, _TypeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        type == TagTypes.stakeholder ? 'Stake holder' : type,
        style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700, fontSize: 11),
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

  _TypeColors _typeColors(String type) {
    switch (type) {
      case TagTypes.project:
        return const _TypeColors(
          fg: AppColors.brandStrong,
          bg: Color(0xFFE8F5EE),
          border: Color(0xFF9FD8B1),
        );
      case TagTypes.stakeholder:
        return const _TypeColors(
          fg: AppColors.success,
          bg: Color(0xFFEAF8F1),
          border: Color(0xFF97D5B8),
        );
      case TagTypes.partner:
        return const _TypeColors(
          fg: AppColors.info,
          bg: Color(0xFFEAF0FD),
          border: Color(0xFF9FB8EE),
        );
      default:
        return const _TypeColors(
          fg: AppColors.textSecondary,
          bg: AppColors.surface,
          border: AppColors.border,
        );
    }
  }
}

class _TypeColors {
  const _TypeColors({required this.fg, required this.bg, required this.border});

  final Color fg;
  final Color bg;
  final Color border;
}
