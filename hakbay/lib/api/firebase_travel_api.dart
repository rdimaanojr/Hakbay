import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTravelApi {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Return travel plans only by the user
  Stream<QuerySnapshot> getUserTravels(String uid) {
    return db.collection('travels').where('uid', isEqualTo: uid).snapshots();
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