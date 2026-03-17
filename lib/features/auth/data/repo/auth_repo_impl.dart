import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/domain/entity/user_entity.dart';
import '../../domain/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  AuthRepoImpl(this._firestore, this._firebaseAuth);

  @override
  Future<UserEntity?> createUserWithEmailAndPassword(
      String name, String email, String password) async {
    try {

      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // 2. Prepare the User Entity
        UserEntity user = UserEntity(
          uid: uid,
          name: name,
          email: email,
        );

        // 3. Update Auth profile (for backup) and Save to Firestore (Primary Source)
        await Future.wait([
          userCredential.user!.updateDisplayName(name),
          _firestore.collection('users').doc(uid).set(user.toJson()),
        ]);

        return user;
      }
    } on FirebaseAuthException catch (e) {
      // Professional Error Handling
      String message = "An error occurred";
      if (e.code == 'email-already-in-use') message = "This email is already registered.";
      if (e.code == 'weak-password') message = "The password is too weak.";
      throw Exception(message);
    } catch (e) {
      throw Exception("Failed to create account. Please try again.");
    }
    return null;
  }

  @override
  Future<UserEntity?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // ALWAYS fetch from Firestore to get the latest profile data
        return await _getUserFromFirestore(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Invalid email or password";
      if (e.code == 'user-disabled') message = "This account has been disabled.";
      throw Exception(message);
    } catch (e) {
      throw Exception("Login failed. Check your connection.");
    }
    return null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Fetch the most up-to-date name/data from Firestore
      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      debugPrint("Error fetching current user: $e");
      return null;
    }
  }

  // Helper method to keep code DRY (Don't Repeat Yourself)
  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserEntity.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception("Failed to log out correctly.");
    }
  }

  @override
  Future<List<UserEntity>> fetchAllUsers() async {
    try {
      // In a "Great" app, you might want to order users by name
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserEntity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all users: $e");
      throw Exception("Could not load users.");
    }
  }
}
