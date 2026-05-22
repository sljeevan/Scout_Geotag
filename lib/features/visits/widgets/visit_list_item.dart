import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../models/visit_model.dart';
import 'visit_status_chip.dart';

class VisitListItem extends StatelessWidget {
  const VisitListItem({super.key, required this.visit});

  final VisitModel visit;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  visit.visitType,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              VisitStatusChip(syncStatus: visit.syncStatus),
            ],
          ),
          if ((visit.discussionPoints ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(visit.discussionPoints!),
          ],
          if ((visit.actionItems ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Action: ${visit.actionItems!}', style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if ((visit.outcomeStatus ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Outcome: ${visit.outcomeStatus!}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
