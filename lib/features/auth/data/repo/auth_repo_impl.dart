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
  Future<UserEntity?> createUserWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserEntity user = UserEntity(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
        );

        // Optionally, save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.name,
          'email': user.email,
        });

        return user;
      }
    } catch (e) {
      debugPrint("Error creating user: $e");
      throw Exception("Failed to create user");
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
        return UserEntity(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
        );
      }
    } catch (e) {
      debugPrint("Error logging in: $e");
      throw Exception("Invalid email or password");
    }
    return null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user != null) {
        return UserEntity(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
      }
    } catch (e) {
      debugPrint("Error fetching current user: $e");
      throw Exception("Failed to fetch current user");
    }
    return null;
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint("Error logging out: $e");
      throw Exception("Failed to log out");
    }
  }

  @override
  Future<List<UserEntity>> fetchAllUsers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserEntity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all users: $e");
      throw Exception("Failed to fetch users");
    }
  }
}

