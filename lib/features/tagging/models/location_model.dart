class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime capturedAt;
  final String? address;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'captured_at': capturedAt.toUtc().toIso8601String(),
        'address': address,
      };
}

enum LocationCaptureState {
  idle,
  loading,
  ready,
  permissionDenied,
  serviceDisabled,
  timeout,
  error,
}

class LocationCaptureResult {
  const LocationCaptureResult({
    required this.state,
    this.location,
    this.message,
  });

  final LocationCaptureState state;
  final LocationModel? location;
  final String? message;
}
