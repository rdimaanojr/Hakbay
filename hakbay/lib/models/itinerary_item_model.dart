import 'location_model.dart';

class ItineraryItem {
  final String name;
  final String? description;
  final DateTime time;
  final Location? location;

  ItineraryItem({
    required this.name,
    required this.time,
    this.description,
    this.location,
  });

  static const _undefined = Object();

  ItineraryItem copyWith({
    String? name,
    DateTime? time,
    Object? description,
    Object? location = _undefined,
  }) {
    return ItineraryItem(
      name: name ?? this.name,
      time: time ?? this.time,
      description:
          description == _undefined ? this.description : description as String?,
      location:
          location == _undefined ? this.location : location as Location?,
    );
  }
}
