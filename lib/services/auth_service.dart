import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  Future<UserCredential> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        debugPrint('Anonymous auth is not enabled.'); 
      } else {
        debugPrint('Error signing in anonymously: ${e.message}');
      }
      rethrow;
    } catch (e) {
      debugPrint('unknown error during anonymous sign-in: $e');
      rethrow;
    }
  }

//if with sign out
  // Future<void> signOut() async {
  //   try {
  //     await _firebaseAuth.signOut();
  //   } catch (e) {
  //     debugPrint('Error signing out: $e');
  //     rethrow;
  //   }
  // }
}