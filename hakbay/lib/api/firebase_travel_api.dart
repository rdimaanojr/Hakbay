import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTravelApi {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Return travel plans only by the user
  Stream<QuerySnapshot> getUserTravels(String uid) {
    return db.collection('travels').where('uid', isEqualTo: uid).snapshots();
  }

  // Get all itinerary items for a specific travel plan
  Stream<QuerySnapshot> getItineraryItems(String travelId) {
    return db
      .collection('travels')
      .doc(travelId)
      .collection('itinerary')
      .orderBy('day')
      .orderBy('startTime')
      .snapshots();
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

  // Add the new itinerary in the database
  Future<String> addItinerary(String travelId, Map<String, dynamic> itinerary) async {
    try {
      // Generate a new document in the subcollection with auto ID
      final docRef = db.collection('travels').doc(travelId).collection('itinerary').doc();
      itinerary['id'] = docRef.id;

      await db.collection('travels').doc(travelId).collection('itinerary').doc(itinerary['id']).set(itinerary);

      return "Successfully added itinerary!";
    } on FirebaseException catch (e) {
      return 'Error: ${e.message}';
    }
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
}