import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;

  // Doctor login method
  Future<bool> loginAsDoctor(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print("Attempting to login as doctor with email: $email");

      UserCredential userCredential;
      try {
        // Try to sign in with email and password
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("Doctor login successful with existing account");
      } catch (e) {
        print("Doctor login failed, creating new account: $e");
        // If sign in fails, create a new account
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("New doctor account created successfully");
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      print("Checking if doctor exists in Firestore: ${userDoc.exists}");

      if (!userDoc.exists) {
        // Create doctor user model if first time sign in
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          patientName: "Dr. Rajneesh Chaudhary",
          phoneNumber: "",
          age: 0,
          userType: 'doctor', // Set userType to 'doctor'
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
        print("Created new doctor record in Firestore");
      } else {
        // Update userType to 'doctor' if not already set
        if (userDoc.data()?['userType'] != 'doctor') {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'userType': 'doctor'});
          print("Updated existing user to doctor type");
        } else {
          print("User already has doctor type");
        }
      }

      return true;
    } catch (e) {
      print("Doctor login error: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Google Sign In Method
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Google sign in cancelled';
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create new user model if first time sign in
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          patientName: user.displayName ?? 'Unknown',
          phoneNumber: user.phoneNumber ?? '',
          age: 0, // Default age, can be updated later
          userType: 'patient', // Set userType to 'patient'
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String patientName,
    required String phoneNumber,
    required int age,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        patientName: patientName,
        phoneNumber: phoneNumber,
        age: age,
        userType: 'patient', // Set userType to 'patient'
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login Method
  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
