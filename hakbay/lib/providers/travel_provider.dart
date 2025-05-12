import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hakbay/api/firebase_travel_api.dart';
import 'package:hakbay/models/travel_plan_model.dart';

// Our provider class
class TravelPlanProvider with ChangeNotifier {
  late Stream<QuerySnapshot> _travelStream;
  late FirebaseTravelApi firebaseService;

  TravelPlanProvider() {
    firebaseService = FirebaseTravelApi();
  }

  // getter for our travel plans database
  Stream<QuerySnapshot> get getTravels => _travelStream;

  // TODO: get travel plans from Firestore
  void fetchTravels(String uid) {
    _travelStream = firebaseService.getUserTravels(uid);
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
  
}