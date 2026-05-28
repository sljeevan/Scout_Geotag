import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/config/status_mapper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../sites/site_detail_screen.dart';
import 'map_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectState>().projects;
    final mappableProjects = projects
        .where((p) => isValidMapCoordinate(p.latitude, p.longitude))
        .toList();
    final markers = mappableProjects
        .map(
          (p) => Marker(
            markerId: MarkerId(p.id?.toString() ?? p.projectName),
            position: LatLng(p.latitude, p.longitude),
            infoWindow: InfoWindow(
              title: p.projectName,
              snippet: normalizeStatus(p.status),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SiteDetailScreen(project: p)),
            ),
          ),
        )
        .toSet();

    final initial = mappableProjects.isNotEmpty
        ? safeMapTarget(
            mappableProjects.first.latitude,
            mappableProjects.first.longitude,
          )
        : fallbackMapTarget;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Site Map',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('All sites plotted',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.x2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: initial, zoom: 11),
                onMapCreated: (c) => _controller = c,
                markers: markers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          AppCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text('Status legend',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                _dot('Active', AppColors.success),
                const SizedBox(width: 8),
                _dot('Hold', AppColors.warning),
                const SizedBox(width: 8),
                _dot('Done', AppColors.info),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          AppButton(
            label: 'Center To First Project',
            icon: Icons.gps_fixed,
            onPressed: mappableProjects.isEmpty
                ? null
                : () => _controller?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(mappableProjects.first.latitude,
                            mappableProjects.first.longitude),
                        15,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(String label, Color c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
