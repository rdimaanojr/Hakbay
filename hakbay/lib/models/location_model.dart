import 'coordinates_model.dart';

class Location {
  final String name;
  final Coordinates? coordinates;

  Location({required this.name, this.coordinates});

  static const _undefined = Object();

  Location copyWith({String? name, Object? coordinates = _undefined}) {
    return Location(
      name: name ?? this.name,
      coordinates:
          coordinates == _undefined
              ? this.coordinates
              : coordinates as Coordinates?,
    );
  }
}
