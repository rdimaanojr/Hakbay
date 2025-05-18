import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_travel_api.dart';
import 'package:hakbay/models/travel_plan_model.dart';
import 'package:hakbay/utils/logger.dart';

// Our provider class
class TravelPlanProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _travelStream;
  late Stream<QuerySnapshot> _sharedStream;
  late Stream<QuerySnapshot> _itineraryStream;
  late FirebaseTravelApi firebaseService;

  TravelPlanProvider() {
    firebaseService = FirebaseTravelApi();
  }

  // getter for our travel plans database
  Stream<QuerySnapshot> get getTravels => _travelStream;
  Stream<QuerySnapshot> get getSharedPlans => _sharedStream;
  Stream<QuerySnapshot> get getItineraryItems => _itineraryStream;


  // TODO: get travel plans from Firestore
  void fetchTravels(String uid) {
    _travelStream = firebaseService.getUserTravels(uid);
    _sharedStream = firebaseService.getSharedPlans(uid);
  }

  void fetchItineraries(String planId) {
    _itineraryStream = firebaseService.getItineraryItems(planId);
  }

  Future<TravelPlan?> fetchTravelById(String planId) async {
    try {
      final doc = await firebaseService.getTravelById(planId);
      if (doc.exists) {
        return TravelPlan.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      logger.e("Failed to fetch travel by ID: $e");
      return null;
    }
  }


  // TODO: add a travel plan and store it in Firestore
  Future<void> addTravel(TravelPlan entry) async {
    String message = await firebaseService.addTravel(entry.toJson());
    print(message);
    notifyListeners();
  }

  // TODO: edit a travel plan and update it in Firestore
  Future<void> editTravel(String id, TravelPlan entry) async {
    String message = await firebaseService.editTravel(id, entry.toJson());
    print(message);
    notifyListeners();
  }

  // TODO: delete a travel plan and update it in Firestore
  Future<void> deleteTravel(String id) async {
    String message = await firebaseService.deleteTravel(id);
    print(message);
    notifyListeners();
  }
  
  // Add a new itinerary item
  Future<String> addItineraryItem(String travelId, ItineraryItem item) async {
    final message = await firebaseService.addItinerary(travelId, item.toJson());
    print(message);
    notifyListeners();
    return message;
  }

  Future<String> updateItinerary(String itineraryId, ItineraryItem item) async {
    final message = await firebaseService.updateItinerary(itineraryId, item.toJson());
    print(message);
    notifyListeners();
    return message;
  }

  Future<String> deleteItinerary(String itineraryId) async {
    final message = await firebaseService.deleteItinerary(itineraryId);
    print(message);
    notifyListeners();
    return message;
  }
}

