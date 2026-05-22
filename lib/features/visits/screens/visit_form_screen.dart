import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/visit_model.dart';
import '../providers/visit_provider.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _discussionCtrl = TextEditingController();
  final _nextActionCtrl = TextEditingController();
  late final DateTime _capturedAt;

  @override
  void initState() {
    super.initState();
    _capturedAt = DateTime.now();
  }

  @override
  void dispose() {
    _discussionCtrl.dispose();
    _nextActionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Captured at: ${_capturedAt.toLocal()}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _discussionCtrl,
            decoration: const InputDecoration(labelText: 'Discussion Points'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nextActionCtrl,
            decoration: const InputDecoration(labelText: 'Next Action (Optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await context.read<VisitProvider>().addVisit(
                    projectId: widget.projectId,
                    visitType: VisitTypes.siteInspection,
                    visitDate: _capturedAt.millisecondsSinceEpoch,
                    startTime: _formatTime(TimeOfDay.fromDateTime(_capturedAt)),
                    endTime: null,
                    discussionPoints: _discussionCtrl.text.trim().isEmpty ? null : _discussionCtrl.text.trim(),
                    actionItems: _nextActionCtrl.text.trim().isEmpty ? null : _nextActionCtrl.text.trim(),
                    outcomeStatus: VisitOutcomeStatus.pendingClarification,
                  );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save Visit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
