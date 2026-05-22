import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/visit_model.dart';

class VisitStatusChip extends StatelessWidget {
  const VisitStatusChip({super.key, required this.syncStatus});

  final String syncStatus;

  @override
  Widget build(BuildContext context) {
    final isSynced = syncStatus == VisitSyncStatus.synced;
    final fg = isSynced ? AppColors.success : AppColors.warning;
    final bg = isSynced ? const Color(0xFFEAF8F1) : const Color(0xFFEEF8F1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(isSynced ? 'Synced' : 'Pending', style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
