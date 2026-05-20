import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:wattwais/models/bill_entry.dart";
import "package:wattwais/models/bill_model.dart";

//handle firestore operations related to bills and budget.
class BillService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  //returns the target month based on predictionTarget.
  //"next_month" → current month
  //"current_month" → previous month
  static DateTime getTargetMonth(String predictionTarget) {
    final now = DateTime.now();

    if (predictionTarget == "next_month") {
      return DateTime(now.year, now.month);
    }
    return DateTime(now.year, now.month - 1);
  }

  //create list of 6 BillEntry objects for the required months.
  //every BillEntry corresponds to one monthId (YYYY-MM).
  static List<BillEntry> generateRequiredMonths(String predictionTarget) {
    final List<BillEntry> bills = [];
    final targetMonth = getTargetMonth(predictionTarget);

    for (int i = 0; i < 6; i++) {
      final date = DateTime(targetMonth.year, targetMonth.month - i);
      final monthId = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      bills.add(BillEntry(monthId: monthId));
    }

    return bills;
  }

  //loads bills from Firestore and pre-fills the BillEntry controllers.
  static Future<void> loadBills(List<BillEntry> bills) async {
    final user = _auth.currentUser;
    if (user == null) return;

    for (final bill in bills) {
      if (bill.isDisposed) continue;
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bills')
          .doc(bill.monthId)
          .get();

      if (doc.exists) {
        final billModel = BillModel.fromMap(doc.data()!);

        if (bill.isDisposed) continue;
        try {
          bill.billController.text = billModel.billAmount.toString();
          if (billModel.kwhUsed != null) {
            bill.kwhController.text = billModel.kwhUsed.toString();
          }
        } catch (_) {
          // Ignore updates if controllers were disposed mid-flight.
        }
      }
    }
  }

  //saves a list of BillEntry objects to Firestore.
  //converts each BillEntry into a BillModel before saving.
  static Future<List<BillModel>> saveBills(List<BillEntry> bills) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final List<BillModel> savedBills = [];

    for (final bill in bills) {
      final billModel = BillModel(
        month: bill.monthId,
        billAmount: double.parse(bill.billController.text),
        kwhUsed: bill.kwhController.text.isEmpty
            ? null
            : double.parse(bill.kwhController.text),
        updatedAt: Timestamp.now(),
      );

      savedBills.add(billModel);

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("bills")
          .doc(bill.monthId)
          .set(billModel.toMap());
    }

    return savedBills;
  }

  //loads the user's budget from Firestore.
  static Future<String?> loadBudget() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('budget')
        .get();

    if (!doc.exists) return null;

    return doc['amount'].toString();
  }

  // save the user's budget to Firestore.
  static Future<void> saveBudget(double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("settings")
        .doc("budget")
        .set({"amount": amount});
  }

  //load base rate from Firestore.
  static Future<String?> loadBaseRate() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    //fetch base rate
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('base_rate')
        .get();

    if (!doc.exists) {
      return null;
    }

    return doc['amount'].toString();
  }

  //save base rate to Firestore.
  static Future<void> saveBaseRate(double amount) async {
    final user = _auth.currentUser;

    if (user == null) return;

    //save base rate value to Firestore under the user's settings
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('base_rate')
        .set({'amount': amount});
  }
}
