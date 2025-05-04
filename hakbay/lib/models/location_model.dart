class Location {
  final double longitude;
  final double latitude;

  Location({required this.longitude, required this.latitude});

  Location copyWith({double? latitude, double? longitude}) {
    return Location(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }
}
