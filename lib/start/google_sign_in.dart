import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'homepage.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;

  Future<void> googleLogin(BuildContext context) async {
    try {
      // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await googleSignIn.initialize(); 
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.authenticate();
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: null, 
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      // Check if user exists in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final docSnapshot = await userDoc.get();

      // If user does NOT exist, create the record
      if (!docSnapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        Navigator.pop(context);
        // 🚀 Navigate to Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      }

      notifyListeners();

    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close loader

      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        return;
      }

      debugPrint('⚠️ Google Sign-In Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In failed, please try again.')),
        );
      }
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await googleSignIn.disconnect(); 
    } catch (_) {
      await googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}