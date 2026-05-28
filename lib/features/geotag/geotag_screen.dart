import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_input.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class GeoTagScreen extends StatefulWidget {
  const GeoTagScreen({super.key});

  @override
  State<GeoTagScreen> createState() => _GeoTagScreenState();
}

class _GeoTagScreenState extends State<GeoTagScreen> {
  final _projectName = TextEditingController();
  final _developer = TextEditingController();
  final _architect = TextEditingController();
  final _pmc = TextEditingController();
  final _facadeConsultant = TextEditingController();
  final _remarks = TextEditingController();
  String _segment = 'Commercial';
  String _status = 'Active';
  String _outcome = 'WON';
  Position? _pos;
  File? _photo;
  DateTime? _capturedAt;

  Future<void> _captureGps() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }
    final p = await Geolocator.getCurrentPosition();
    setState(() {
      _pos = p;
      _capturedAt = DateTime.now();
    });
  }

  Future<void> _capturePhoto() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 75);
    if (x != null) {
      setState(() => _photo = File(x.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProjectState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tag a Site',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Geo-pin your current location',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.x2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('GPS Coordinates',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.x1),
                AppButton(
                    label: 'Capture GPS',
                    icon: Icons.my_location,
                    onPressed: _captureGps),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  _pos == null
                      ? 'GPS status: Not captured'
                      : 'GPS status: ${_pos!.latitude.toStringAsFixed(6)}, ${_pos!.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _pos == null
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                ),
                if (_capturedAt != null)
                  Text('Captured at: ${_capturedAt!.toLocal()}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Site Details',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.x2),
                AppInput(label: 'Project Name *', controller: _projectName),
                const SizedBox(height: AppSpacing.x2),
                AppInput(label: 'Client', controller: _developer),
                const SizedBox(height: AppSpacing.x2),
                AppInput(label: 'Architect', controller: _architect),
                const SizedBox(height: AppSpacing.x2),
                AppInput(label: 'PMC', controller: _pmc),
                const SizedBox(height: AppSpacing.x2),
                AppInput(
                    label: 'Facade Consultant', controller: _facadeConsultant),
                const SizedBox(height: AppSpacing.x2),
                DropdownButtonFormField<String>(
                  initialValue: _segment,
                  style: const TextStyle(color: AppColors.textPrimary),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(
                        value: 'Commercial', child: Text('Commercial')),
                    DropdownMenuItem(value: 'Housing', child: Text('Housing')),
                  ],
                  onChanged: (v) =>
                      setState(() => _segment = v ?? 'Commercial'),
                  decoration: const InputDecoration(labelText: 'Segment *'),
                ),
                const SizedBox(height: AppSpacing.x2),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  style: const TextStyle(color: AppColors.textPrimary),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'On Hold', child: Text('On Hold')),
                    DropdownMenuItem(
                        value: 'Completed', child: Text('Completed')),
                    DropdownMenuItem(
                        value: 'Cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'Active'),
                  decoration: const InputDecoration(labelText: 'Status *'),
                ),
                if (_status == 'Completed') ...[
                  const SizedBox(height: AppSpacing.x2),
                  DropdownButtonFormField<String>(
                    initialValue: _outcome,
                    style: const TextStyle(color: AppColors.textPrimary),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: 'WON', child: Text('WON')),
                      DropdownMenuItem(value: 'LOST', child: Text('LOST')),
                    ],
                    onChanged: (v) => setState(() => _outcome = v ?? 'WON'),
                    decoration: const InputDecoration(labelText: 'Outcome *'),
                  ),
                ],
                const SizedBox(height: AppSpacing.x2),
                AppInput(label: 'Remarks', controller: _remarks, maxLines: 3),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Site Photo',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.x1),
                AppButton(
                    label: 'Capture Site Photo',
                    icon: Icons.camera_alt_outlined,
                    onPressed: _capturePhoto),
                if (_photo != null) ...[
                  const SizedBox(height: AppSpacing.x2),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          Image.file(_photo!, height: 180, fit: BoxFit.cover)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          AppButton(
            label: state.saving ? 'Saving...' : 'Save Site',
            icon: Icons.save_outlined,
            onPressed: state.saving
                ? null
                : () async {
                    if (_projectName.text.trim().isEmpty || _pos == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Project name and GPS are required')));
                      return;
                    }
                    await context.read<ProjectState>().saveGeotag(
                          projectName: _projectName.text.trim(),
                          developer: _developer.text.trim().isEmpty
                              ? null
                              : _developer.text.trim(),
                          architect: _architect.text.trim().isEmpty
                              ? null
                              : _architect.text.trim(),
                          pmc: _pmc.text.trim().isEmpty
                              ? null
                              : _pmc.text.trim(),
                          facadeConsultant:
                              _facadeConsultant.text.trim().isEmpty
                                  ? null
                                  : _facadeConsultant.text.trim(),
                          segment: _segment,
                          status: _status,
                          outcome: _status == 'Completed' ? _outcome : null,
                          remarks: _remarks.text.trim().isEmpty
                              ? null
                              : _remarks.text.trim(),
                          latitude: _pos!.latitude,
                          longitude: _pos!.longitude,
                          photo: _photo,
                        );
                  },
          ),
          if (state.error != null) ...[
            const SizedBox(height: AppSpacing.x2),
            Text(state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
