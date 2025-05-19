import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTravelApi {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Return travel plans only by the user
  Stream<QuerySnapshot> getUserTravels(String uid) {
    return db.collection('travels').where('uid', isEqualTo: uid).snapshots();
  }

  // Return travel plans by shared users
  Stream<QuerySnapshot> getSharedPlans(String uid) {
    return db.collection('travels').where('sharedWith', arrayContains: uid).snapshots();
  }

  // Get all itinerary items for a specific travel plan
   Stream<QuerySnapshot> getItineraryItems(String planId) {
    return db.collection('travels').doc(planId).collection('itinerary').snapshots();
  }

  Future<String> updateItinerary(
    String itemId,
    Map<String, dynamic> data
  ) async {
    try {
      // Find the travel document containing the itinerary item
      final travelsSnapshot = await db.collection('travels').get();
      bool updated = false;

      for (var travelDoc in travelsSnapshot.docs) {
        final itineraryDoc = await db
            .collection('travels')
            .doc(travelDoc.id)
            .collection('itinerary')
            .doc(itemId)
            .get();

        if (itineraryDoc.exists) {
          await db
              .collection('travels')
              .doc(travelDoc.id)
              .collection('itinerary')
              .doc(itemId)
              .update(data);
          updated = true;
          break;
        }
      }

      if (updated) {
        return "Successfully updated itinerary item!";
      } else {
        return "Itinerary item not found!";
      }
    } on FirebaseException catch (e) {
      return 'Error updating itinerary: ${e.message}';
    }
  }
  
  Future<String> deleteItinerary(String itemId) async {
    try {
      // Find the travel document containing the itinerary item
      final travelsSnapshot = await db.collection('travels').get();
      bool deleted = false;

      for (var travelDoc in travelsSnapshot.docs) {
        final itineraryDoc = await db
            .collection('travels')
            .doc(travelDoc.id)
            .collection('itinerary')
            .doc(itemId)
            .get();

        if (itineraryDoc.exists) {
          await db
              .collection('travels')
              .doc(travelDoc.id)
              .collection('itinerary')
              .doc(itemId)
              .delete();
          deleted = true;
          break;
        }
      }

      if (deleted) {
        return "Successfully deleted itinerary item!";
      } else {
        return "Itinerary item not found!";
      }
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

  // Get a specific travel plan
  Future<DocumentSnapshot<Map<String, dynamic>>> getTravelById(String planId) {
    return db.collection('travels').doc(planId).get();
  }

  // Add user uid to sharedWith field of travel plan
  Future<String> shareTravelWithUser(String planId, String userUid) async {
    try {
      await db.collection('travels').doc(planId).update({
        'sharedWith': FieldValue.arrayUnion([userUid]),
      });

      return "Successfully shared travel plan!";
    } on FirebaseException catch (e) {
      return 'Error sharing travel plan: ${e.message}';
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