import "package:flutter/material.dart";
import "package:wattwais/wattwais.dart";
import "package:firebase_core/firebase_core.dart";
import "firebase_options.dart";

/*
App entry point for the WattwAIs app
WattwAIs - an electricity consumption monitoring and prediction app 
built using Flutter, Dart, Firebase as DB and XGBoost model for ML prediction
Uses anonymous auth
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const WattwAIsApp());
}
