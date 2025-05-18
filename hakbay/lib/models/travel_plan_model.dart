import 'package:flutter/material.dart';

class ItineraryItem {
  String? id;
  final String name;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final DateTime date;

  ItineraryItem({
    this.id,
    required this.name,
    this.startTime,
    this.endTime,
    required this.location,
    required this.date
  });

  ItineraryItem copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    DateTime? date,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      date: date ?? this.date
    );
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      date: DateTime.parse(json['date'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'date': date.toIso8601String(),
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
    String? planId,
    String? name,
    DateTimeRange? travelDate,
    String? location,
    // Location? location,
    Object? details = _undefined,
    Object? itinerary = _undefined,
  }) {
    return TravelPlan(
      uid: uid ?? this.uid,
      planId: planId ?? this.planId,
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
