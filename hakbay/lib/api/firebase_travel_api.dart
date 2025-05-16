import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hakbay/models/travel_plan_model.dart';

class FirebaseTravelApi {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  
  String? _currentTravelId;

  void setCurrentTravelId(String id) {
    _currentTravelId = id;
  }

  String? get currentTravelId => _currentTravelId;

  // Return travel plans only by the user
  Stream<QuerySnapshot> getUserTravels(String uid) {
    return db.collection('travels').where('uid', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> getItineraryItems(String travelId) {
    return db.collection('travels')
      .doc(travelId)
      .collection('itinerary')
      .orderBy('day')
      .orderBy('startTime')
      .snapshots();
  }

  // Add the new travel plan in the database
  Future<String> addTravel(Map<String, dynamic> travel) async {
    try {
      // Get the ID and set it to the entry
      travel['planId'] = db.collection('travels').doc().id;
      await db.collection('travels').doc(travel['planId']).set(travel);

      return "Successfully added travel plan!";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  // Delete the travel plan in the database
  Future<String> deleteTravel(String planId) async {
    try {
      await db.collection('travels').doc(planId).delete();

      return "Successfully deleted travel plan!";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  // Edit the travel plan in the database
  Future<String> editTravel(String planId, Map<String, dynamic> travel) async {
    try {
      await db.collection('travels').doc(planId,).update(travel);
      
      return "Successfully edited travel plan!";
    } on FirebaseException catch (e) {
      return 'Error on ${e.message}';
    }
  }

  Future<String> addItinerary(String travelId, ItineraryItem item, int dayNumber) async {
    try {
      // First verify the travel plan exists
      final travelDoc = await db.collection('travels').doc(travelId).get();
      
      if (!travelDoc.exists) {
        return 'Error: Travel plan does not exist';
      }

      // Create a new document in the itinerary subcollection
      final docRef = db.collection('travels')
        .doc(travelId)
        .collection('itinerary')
        .doc();
      
      // Set the item's ID and day number
      item.id = docRef.id;
      item.day = dayNumber;

      // Convert to JSON for storage
      final itemData = item.toJson();

      // Batch write to update both the subcollection and the main document
      final batch = db.batch();
      
      // Add to subcollection
      batch.set(docRef, itemData);
      
      // Update the itinerary array in the travel document
      batch.update(
        db.collection('travels').doc(travelId),
        {
          'itinerary': FieldValue.arrayUnion([itemData])
        }
      );

      // Commit the batch
      await batch.commit();

      return "Successfully added itinerary item!";
    } on FirebaseException catch (e) {
      return 'Error adding itinerary: ${e.message}';
    }
  }

  Future<String> updateItinerary(
    String travelId, 
    String itemId, 
    Map<String, dynamic> data
  ) async {
    try {
      await db.collection('travels')
        .doc(travelId)
        .collection('itinerary')
        .doc(itemId)
        .update(data);

      return "Successfully updated itinerary item!";
    } on FirebaseException catch (e) {
      return 'Error updating itinerary: ${e.message}';
    }
  }
  
  Future<String> deleteItinerary(String travelId, String itemId) async {
    try {
      await db.collection('travels')
        .doc(travelId)
        .collection('itinerary')
        .doc(itemId)
        .delete();

      return "Successfully deleted itinerary item!";
    } on FirebaseException catch (e) {
      return 'Error deleting itinerary: ${e.message}';
    }
  }

  Future<DocumentSnapshot> getItineraryItemById(
    String travelId, 
    String itemId
  ) async {
    return await db.collection('travels')
      .doc(travelId)
      .collection('itinerary')
      .doc(itemId)
      .get();
  }

}