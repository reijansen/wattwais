import "package:flutter/material.dart";

//bill entry for a given month.
//hold controllers for bill amount and kWh usage.
class BillEntry {
  //unique identifier for the month (format: yyyy-mm, ex. "2026-05").
  final String monthId;

  //controller for the bill amount input field.
  final TextEditingController billController = TextEditingController(text: "0");

  //controller for the kWh usage input field.
  final TextEditingController kwhController = TextEditingController(text: "0");

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  BillEntry({required this.monthId});

  //dispose controllers to prevent memory leaks.
  void dispose() {
    _isDisposed = true;
    billController.dispose();
    kwhController.dispose();
  }
}
