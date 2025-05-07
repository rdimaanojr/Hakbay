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
      latitude: latitude == _undefined ? this.latitude : latitude as double?,
    );
  }
<<<<<<< HEAD
}
=======

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      longitude:
          json['longitude'] != null
              ? double.tryParse(json['longitude'].toString())
              : null,
      latitude:
          json['latitude'] != null
              ? double.tryParse(json['latitude'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'longitude': longitude, 'latitude': latitude};
  }
}
>>>>>>> 1e454cf (feat: IMPLEMENT models)
