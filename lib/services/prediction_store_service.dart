import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:wattwais/models/bill_model.dart";
import "package:wattwais/models/prediction_result.dart";

// For saving prediction results into Firestore.
class PredictionStoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Save prediction record to Firestore under the current user.
  //
  // Parameters:
  // - [predictionTarget]: "current_month" or "next_month"
  // - [budget]: the monthly budget entered by the user
  // - [bills]: list of BillModel objects representing the 6 months of bills
  // - [predictionResult]: optional API result to store alongside inputs
  //
  // Throws exception if the user is not authenticated.
  static Future<void> savePrediction({
    required String predictionTarget,
    required double budget,
    required List<BillModel> bills,
    required double baseRate,
    required List appliances,
    PredictionResult? predictionResult,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bill_predictions')
        .add({
      'prediction_target': predictionTarget,
      'budget': budget,
      'bills': bills.map((bill) => bill.toMap()).toList(),
      'base_rate': baseRate,
      'appliances': appliances.map((appliance) {
        try {
          return (appliance as dynamic).toMap();
        } catch (_) {
          try {
            return (appliance as dynamic).toJson();
          } catch (_) {
            return appliance;
          }
        }
      }).toList(),
      if (predictionResult != null) 'prediction_result': predictionResult.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Stream<Map<String, dynamic>?> streamLatestPrediction() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bill_predictions')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    });
  }
}
