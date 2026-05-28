import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng fallbackMapTarget = LatLng(12.9716, 77.5946);

bool isValidMapCoordinate(double latitude, double longitude) {
  if (!latitude.isFinite || !longitude.isFinite) return false;
  if (latitude < -90 || latitude > 90) return false;
  if (longitude < -180 || longitude > 180) return false;
  return true;
}

LatLng safeMapTarget(double latitude, double longitude) {
  if (isValidMapCoordinate(latitude, longitude)) {
    return LatLng(latitude, longitude);
  }
  return fallbackMapTarget;
}
