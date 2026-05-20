import "package:cloud_firestore/cloud_firestore.dart";

//represents a bill stored in Firestore.
class BillModel {
  final String month;          //"2026-05"
  final double billAmount;     //peso amount
  final double? kwhUsed;       //kWh usage (optional for now)
  final Timestamp? updatedAt;  //firestore server timestamp

  BillModel({
    required this.month,
    required this.billAmount,
    this.kwhUsed,
    this.updatedAt,
  });

  //from firestore doc snapshot
  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      month: map['month'] as String,
      billAmount: (map['bill_amount'] as num).toDouble(),
      kwhUsed: map['kwh_used'] != null
          ? (map['kwh_used'] as num).toDouble()
          : null,
      updatedAt: map['updated_at'] as Timestamp?,
    );
  }

  //to firestore
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'bill_amount': billAmount,
      'kwh_used': kwhUsed,
      'updated_at': updatedAt,
    };
  }
}
