import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gdsc360/pages/Login.dart';
import 'package:gdsc360/utils/locationservice.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationTrackingService _locationTrackingService =
      LocationTrackingService();

  //start of sign up functions
  Future<void> createUserAuth(
      String email, String password, String confirmPassword) async {
    try {
      if (password == confirmPassword) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        await addUserData(userCredential);
        _locationTrackingService.startTracking();
      } else {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'Passwords do not match',
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addUserData(UserCredential userCredential) async {
    String email = userCredential.user?.email ?? '';
    String name = email.split('@')[0];
    String? uid = userCredential.user?.uid;

    if (uid != null) {
      await _firestore.collection('users').doc(uid).set({
        'userID': uid,
        'email': email,
        'phone_number': 0,
        'name': name,
        'profile_pic': '',
        'role': ''
      });
    } else {
      print("Error: UID is null");
    }
  }

  //start of login functions
  Future<void> loginUserAuth(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _locationTrackingService.startTracking();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOutAuth(BuildContext context) async {
    // Sign out the current user
    try {
      await _auth.signOut();
      _locationTrackingService.stopTracking();
      // Navigate to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false, // Clear all existing routes
      );
    } catch (e) {
      // Handle sign-out errors
      print("Sign out error: $e");
      rethrow;
    }
  }

  String? getCurrentUserUid() {
    //get the id of the current user
    User? currentUser = _auth.currentUser;
    return currentUser?.uid.toString();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    //gets a specfic users data
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No user found with uid: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> currUserData() async {
    //get current user data
    String? currentUserUID = getCurrentUserUid();

    if (currentUserUID != null) {
      Map<String, dynamic>? userData = await getUserData(currentUserUID);
      print(userData);
      return userData;
    } else {
      print("No user is currently signed in.");
      return null;
    }
  }

  Future<void> updateUserDetail(String fieldName, dynamic newValue) async {
    try {
      String? currentUserUID = getCurrentUserUid();
      if (currentUserUID != null) {
        await _firestore.collection('users').doc(currentUserUID).update({
          fieldName: newValue,
        });
        print("Change successful!");
      } else {
        print("Error: No current user logged in.");
      }
    } catch (e) {
      print("Error updating user field: $e");
      rethrow;
    }
  }
}
