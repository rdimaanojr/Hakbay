class Location {
  final String name;
  final double? longitude;
  final double? latitude;

  Location({required this.name, this.longitude, this.latitude});

  static const _undefined = Object();

  Location copyWith({
    String? name,
    Object? longitude = _undefined,
    Object? latitude = _undefined,
  }) {
    return Location(
      name: name ?? this.name,
      longitude:
          longitude == _undefined ? this.longitude : longitude as double?,
      latitude:
          latitude == _undefined ? this.latitude : latitude as double?,
    );
  }
}