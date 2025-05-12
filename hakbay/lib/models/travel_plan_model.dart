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
      location: location == _undefined ? this.location : location as Location?,
    );
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      name: json['name'],
      description: json['description'],
      time: DateTime.parse(json['time']),
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'time': time.toIso8601String(),
      'location': location?.toJson(),
    };
  }
}

class TravelPlan {
  final String? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Location location;
  final String? accomodation;
  final String? notes;
  final List<String>? checklist;
  final Map<int, ItineraryItem>? itinerary;

  TravelPlan({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.accomodation,
    this.notes,
    this.checklist,
    this.itinerary,
  });

  static const _undefined = Object();

  TravelPlan copyWith({
    Object? id = _undefined,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    Location? location,
    Object? accomodation = _undefined,
    Object? notes = _undefined,
    Object? checklist = _undefined,
    Object? itinerary = _undefined,
  }) {
    return TravelPlan(
      id: id == _undefined ? this.id : id as String?,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      accomodation: accomodation == _undefined ? this.accomodation : accomodation as String?,
      notes: notes == _undefined ? this.notes : notes as String?,
      checklist: checklist == _undefined ? this.checklist : (checklist as List<String>?)?.toList(),
      itinerary: itinerary == _undefined
          ? this.itinerary
          : (itinerary as Map<int, ItineraryItem>?),
    );
  }

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: Location.fromJson(json['location']),
      accomodation: json['accomodation'],
      notes: json['notes'],
      checklist: List<String>.from(json['checklist'] ?? []),
      itinerary: (json['itinerary'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), ItineraryItem.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location.toJson(),
      'accomodation': accomodation,
      'notes': notes,
      'checklist': checklist,
      'itinerary': itinerary?.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
    };
  }
}
