import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/widgets/app_button.dart';
import '../../data/models/tag_entry.dart';
import '../../theme/app_spacing.dart';
import '../tagging/config/form_config.dart';
import '../tagging/config/tag_constants.dart';

class TagEditScreen extends StatefulWidget {
  const TagEditScreen({super.key, required this.tag});

  final TagEntry tag;

  @override
  State<TagEditScreen> createState() => _TagEditScreenState();
}

class _TagEditScreenState extends State<TagEditScreen> {
  late final TextEditingController _entityName;
  late final TextEditingController _contact;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;

  late double _lat;
  late double _lng;
  late String _category;
  bool _locating = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _entityName = TextEditingController(text: widget.tag.entityName);
    _contact = TextEditingController(text: widget.tag.contactPerson ?? '');
    _phone = TextEditingController(text: widget.tag.phone ?? '');
    _email = TextEditingController(text: widget.tag.email ?? '');
    _address = TextEditingController(text: widget.tag.address ?? '');
    _lat = widget.tag.latitude;
    _lng = widget.tag.longitude;
    _latitude = TextEditingController(text: _lat.toStringAsFixed(6));
    _longitude = TextEditingController(text: _lng.toStringAsFixed(6));
    _category = widget.tag.category;
  }

  @override
  void dispose() {
    _entityName.dispose();
    _contact.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
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
    } on TimeoutException {
      // keep previous coordinates
    } catch (_) {
      // keep previous coordinates
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _updateLatLng(double lat, double lng, {bool animate = false}) {
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
    if (_entityName.text.trim().isEmpty) return;

    final updated = TagEntry(
      id: widget.tag.id,
      tagType: widget.tag.tagType,
      category: _category,
      entityName: _entityName.text.trim(),
      contactPerson: _contact.text.trim().isEmpty ? null : _contact.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      latitude: double.tryParse(_latitude.text.trim()) ?? _lat,
      longitude: double.tryParse(_longitude.text.trim()) ?? _lng,
      capturedAt: DateTime.now().millisecondsSinceEpoch,
    );

    Navigator.of(context).pop(updated);
  }

  String _entityLabel() {
    switch (widget.tag.tagType) {
      case TagTypes.stakeholder:
        return 'Company / Firm Name';
      case TagTypes.partner:
        return 'Partner Company Name';
      default:
        return 'Entity Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = TagFormConfig.categoriesForTagType(widget.tag.tagType);
    if (!categories.contains(_category) && categories.isNotEmpty) {
      _category = categories.first;
    }

    final marker = Marker(
      markerId: const MarkerId('tag_pin'),
      position: LatLng(_lat, _lng),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('EDIT')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x3),
        children: [
          TextField(
            controller: _entityName,
            decoration: InputDecoration(labelText: _entityLabel()),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _contact,
            decoration: const InputDecoration(labelText: 'Contact Person'),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: AppSpacing.x2),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 230,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: LatLng(_lat, _lng), zoom: 15),
                onMapCreated: (c) => _mapController = c,
                markers: {marker},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onTap: (latLng) => _updateLatLng(latLng.latitude, latLng.longitude),
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
            value: _category,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Category'),
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
