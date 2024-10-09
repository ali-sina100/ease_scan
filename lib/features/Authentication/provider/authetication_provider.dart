// This class acts as Controller for between Firebase Repository and UI

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repository/firebase_repository.dart';

class AuthenticationProvider with ChangeNotifier {
  late final FirebaseRepository _firebaseRepository;
  late final FirebaseAuth _firebaseAuth;
  late final GoogleSignIn _googleSignIn;

  User? _user;

  AuthenticationProvider() {
    _firebaseAuth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();

    _firebaseRepository = FirebaseRepository(
        firebaseAuth: _firebaseAuth, googleSignIn: _googleSignIn);
    _user = FirebaseAuth.instance.currentUser;
  }

  User? get user => _user;

  // Method to register a new user with email and password
  Future<void> registerWithEmailPassword(String email, String password) async {
    try {
      User? user =
          await _firebaseRepository.registerWithEmailPassword(email, password);
      _user = user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Method to check if a user is signed in
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Method to get the current user
  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try{

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch(e){
      rethrow; 
    }
  }

  // Method to send verification email
  void sendVerificationEmail() {
    _user!.sendEmailVerification();
  }

  // is user verified
  bool isUserVerified() {
    // If user is not verified then send verification email
    if (!_user!.emailVerified) {
      sendVerificationEmail();
    }
    return _user!.emailVerified;
  }

  // Method to sign in a user with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      User? user =
          await _firebaseRepository.signInWithEmailPassword(email, password);
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Method to sign in a user with Google
  Future<User?> signInWithGoogle() async {
    try {
      User? user = await _firebaseRepository.signInWithGoogle();
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
      _googleSignIn.signOut();
    }
    _user = null;
    notifyListeners();
  }
}
