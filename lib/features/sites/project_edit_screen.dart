import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/widgets/app_button.dart';
import '../../data/models/project_models.dart';
import '../../features/map/map_utils.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class ProjectEditScreen extends StatefulWidget {
  const ProjectEditScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _client;
  late final TextEditingController _remarks;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;

  late String _segment;
  late String _status;
  late double _lat;
  late double _lng;

  GoogleMapController? _mapController;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.project.projectName);
    _client = TextEditingController(text: widget.project.developer ?? '');
    _remarks = TextEditingController(text: widget.project.remarks ?? '');
    final target =
        safeMapTarget(widget.project.latitude, widget.project.longitude);
    _lat = target.latitude;
    _lng = target.longitude;
    _latitude = TextEditingController(text: _lat.toStringAsFixed(6));
    _longitude = TextEditingController(text: _lng.toStringAsFixed(6));
    _segment = widget.project.segment;
    _status = widget.project.status;
  }

  @override
  void dispose() {
    _name.dispose();
    _client.dispose();
    _remarks.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      _updateLatLng(pos.latitude, pos.longitude, animate: true);
    } catch (_) {
      // Keep previous location if current fetch fails.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _updateLatLng(double lat, double lng, {bool animate = false}) {
    if (!isValidMapCoordinate(lat, lng)) return;
    setState(() {
      _lat = lat;
      _lng = lng;
      _latitude.text = _lat.toStringAsFixed(6);
      _longitude.text = _lng.toStringAsFixed(6);
    });
    if (animate) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat, _lng), 16),
      );
    }
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    final lat = double.tryParse(_latitude.text.trim()) ?? _lat;
    final lng = double.tryParse(_longitude.text.trim()) ?? _lng;

    final updated = Project(
      id: widget.project.id,
      remoteId: widget.project.remoteId,
      userId: widget.project.userId,
      projectName: _name.text.trim(),
      developer: _client.text.trim().isEmpty ? null : _client.text.trim(),
      architect: widget.project.architect,
      pmc: widget.project.pmc,
      facadeConsultant: widget.project.facadeConsultant,
      segment: _segment,
      status: _status,
      outcome: widget.project.outcome,
      remarks: _remarks.text.trim().isEmpty ? null : _remarks.text.trim(),
      latitude: lat,
      longitude: lng,
      photoPath: widget.project.photoPath,
      createdAt: widget.project.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('site_pin'),
      position: LatLng(_lat, _lng),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('EDIT')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x3),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Project Name'),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _client,
            decoration:
                const InputDecoration(labelText: 'Project Owner / Client'),
          ),
          const SizedBox(height: AppSpacing.x2),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 230,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: safeMapTarget(_lat, _lng), zoom: 15),
                onMapCreated: (c) => _mapController = c,
                markers: {marker},
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                onTap: (latLng) =>
                    _updateLatLng(latLng.latitude, latLng.longitude),
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          AppButton(
            label: _locating ? 'Locating...' : 'Use Current Location',
            icon: Icons.my_location,
            onPressed: _locating ? null : _useCurrentLocation,
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _latitude,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Latitude'),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              if (parsed != null) _updateLatLng(parsed, _lng);
            },
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _longitude,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Longitude'),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              if (parsed != null) _updateLatLng(_lat, parsed);
            },
          ),
          const SizedBox(height: AppSpacing.x1),
          DropdownButtonFormField<String>(
            value: _segment,
            style: const TextStyle(color: AppColors.textPrimary),
            dropdownColor: AppColors.surface,
            items: const [
              DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
              DropdownMenuItem(
                  value: 'Residential', child: Text('Residential')),
              DropdownMenuItem(
                  value: 'Hospitality', child: Text('Hospitality')),
              DropdownMenuItem(value: 'Retail', child: Text('Retail')),
              DropdownMenuItem(value: 'Pvt Homes', child: Text('Pvt Homes')),
            ],
            onChanged: (v) => setState(() => _segment = v ?? _segment),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: AppSpacing.x1),
          DropdownButtonFormField<String>(
            value: _status,
            style: const TextStyle(color: AppColors.textPrimary),
            dropdownColor: AppColors.surface,
            items: const [
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'On Hold', child: Text('On Hold')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _remarks,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Remarks'),
          ),
          const SizedBox(height: AppSpacing.x2),
          AppButton(
            label: 'SAVE',
            icon: Icons.save_outlined,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
