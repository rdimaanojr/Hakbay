import 'location_model.dart';
import 'itinerary_item_model.dart';

class TravelPlan {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Location location;
  final String? accomodation;
  final String? notes;
  final List<String>? checklist;
  final List<ItineraryItem>? itinerary;

  TravelPlan({
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
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    Location? location,
    Object? accomodation = _undefined,
    Object? notes = _undefined,
    Object? checklist = _undefined,
    Object itinerary = _undefined,
  }) {
    return TravelPlan(
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      accomodation: accomodation == _undefined ? this.accomodation : accomodation as String?,
      notes: notes == _undefined ? this.notes : notes as String?,
      checklist: checklist == _undefined ? this.checklist : (checklist as List<String>?)?.toList(),
      itinerary: itinerary == _undefined ? this.itinerary : (checklist as List<ItineraryItem>?)?.toList(),
    );
  }
}
