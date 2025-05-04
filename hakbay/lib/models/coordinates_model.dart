class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates({required this.longitude, required this.latitude});

  Coordinates copyWith({double? latitude, double? longitude}) {
    return Coordinates(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }
}
