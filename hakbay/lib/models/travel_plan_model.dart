import 'package:flutter/material.dart';

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
  final String? uid;
  final String? planId;
  final String name;
  final DateTimeRange travelDate;
  // Temporarily set it to String
  final String location;
  // final Location location;
  final String? details;
  final Map<int, ItineraryItem>? itinerary;

  TravelPlan({
    required this.uid,
    this.planId,
    required this.name,
    required this.travelDate,
    required this.location,
    this.details,
    this.itinerary,
  });

  static const _undefined = Object();

  TravelPlan copyWith({
    String? uid,
    Object? id = _undefined,
    String? name,
    DateTimeRange? travelDate,
    String? location,
    // Location? location,
    Object? details = _undefined,
    Object? itinerary = _undefined,
  }) {
    return TravelPlan(
      uid: uid ?? this.uid,
      planId: id == _undefined ? planId : id as String?,
      name: name ?? this.name,
      travelDate: travelDate ?? this.travelDate,
      location: location ?? this.location,
      details: details == _undefined ? this.details : details as String?,
      itinerary: itinerary == _undefined
          ? this.itinerary
          : (itinerary as Map<int, ItineraryItem>?),
    );
  }

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      uid: json['uid'],
      planId: json['planId'],
      name: json['name'],
      travelDate: DateTimeRange(
        start: DateTime.parse(json['start']), 
        end: DateTime.parse(json['end'])
      ),
      location: json['location'],
      // location: Location.fromJson(json['location']),
      details: json['details'],
      itinerary: (json['itinerary'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(int.parse(key), ItineraryItem.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'planId': planId,
      'name': name,
      'start': travelDate.start.toIso8601String(),
      'end': travelDate.end.toIso8601String(),
      'location': location,
      // 'location': location.toJson(),
      'details': details,
      'itinerary': itinerary?.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
    };
  }
}
