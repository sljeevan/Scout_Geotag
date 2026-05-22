import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationService {
  Future<LocationCaptureResult> captureCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationCaptureResult(
          state: LocationCaptureState.serviceDisabled,
          message: 'Location service is disabled. Enable GPS and retry.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationCaptureResult(
          state: LocationCaptureState.permissionDenied,
          message:
              'Location permission denied. Allow location access to continue.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = [
            p.name,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country,
          ].where((part) => part != null && part!.trim().isNotEmpty).join(', ');
        }
      } catch (_) {
        address = null;
      }

      return LocationCaptureResult(
        state: LocationCaptureState.ready,
        location: LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          capturedAt: DateTime.now(),
          address: address,
        ),
      );
    } on TimeoutException {
      return const LocationCaptureResult(
        state: LocationCaptureState.timeout,
        message:
            'Timed out while fetching GPS. Move to an open area and retry.',
      );
    } catch (e) {
      return LocationCaptureResult(
        state: LocationCaptureState.error,
        message: 'Failed to capture location: $e',
      );
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
