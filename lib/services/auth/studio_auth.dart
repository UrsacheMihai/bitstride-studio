import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// Handle Firebase authentication for Studio users.
class StudioAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: kIsWeb
        ? null
        : '1009649189286-0lbtu6mj0766nilqk2ev61oon85lpkg0.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authChanges => _auth.authStateChanges();

  // Sign in with Google using a popup on web or native sign-in on mobile.
}