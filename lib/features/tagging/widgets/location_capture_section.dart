import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../models/location_model.dart';

class LocationCaptureSection extends StatelessWidget {
  const LocationCaptureSection({
    super.key,
    required this.state,
    required this.location,
    required this.message,
    required this.onRefresh,
    required this.onOpenLocationSettings,
    required this.onOpenAppSettings,
    required this.onManualFieldChanged,
  });

  final LocationCaptureState state;
  final LocationModel? location;
  final String? message;
  final VoidCallback onRefresh;
  final VoidCallback onOpenLocationSettings;
  final VoidCallback onOpenAppSettings;
  final void Function(String key, String value) onManualFieldChanged;

  @override
  Widget build(BuildContext context) {
    final locationReady = location != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location Capture',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.x1),
          Text(
            locationReady
                ? 'Current location captured'
                : 'Location will be auto-captured when screen opens.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.x2),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: state == LocationCaptureState.loading
                      ? 'Fetching...'
                      : 'Refresh Location',
                  icon: Icons.my_location,
                  onPressed:
                      state == LocationCaptureState.loading ? null : onRefresh,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          _statusBlock(context),
          if (!locationReady) ...[
            const SizedBox(height: AppSpacing.x2),
            const Text('Manual Fallback',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.x1),
            TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Latitude'),
              onChanged: (value) => onManualFieldChanged('latitude', value),
            ),
            const SizedBox(height: AppSpacing.x1),
            TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Longitude'),
              onChanged: (value) => onManualFieldChanged('longitude', value),
            ),
            const SizedBox(height: AppSpacing.x1),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Resolved Address (optional)'),
              onChanged: (value) => onManualFieldChanged('address', value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBlock(BuildContext context) {
    Color color = AppColors.info;
    if (state == LocationCaptureState.permissionDenied ||
        state == LocationCaptureState.error ||
        state == LocationCaptureState.serviceDisabled ||
        state == LocationCaptureState.timeout) {
      color = AppColors.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location != null) ...[
          Text('Latitude: ${location!.latitude.toStringAsFixed(6)}'),
          Text('Longitude: ${location!.longitude.toStringAsFixed(6)}'),
          Text('Accuracy: ${location!.accuracy.toStringAsFixed(1)} m'),
          Text('Captured At: ${location!.capturedAt.toLocal()}'),
          Text('Address: ${location!.address ?? 'Not resolved'}'),
          if (location!.accuracy > 30)
            const Text('GPS signal is weak. Consider refreshing in open sky.'),
        ] else
          Text(
            message ?? 'Location not available yet.',
            style: TextStyle(color: color),
          ),
        if (state == LocationCaptureState.serviceDisabled)
          TextButton(
              onPressed: onOpenLocationSettings,
              child: const Text('Open Location Settings')),
        if (state == LocationCaptureState.permissionDenied)
          TextButton(
              onPressed: onOpenAppSettings,
              child: const Text('Open App Settings')),
      ],
    );
  }
}
