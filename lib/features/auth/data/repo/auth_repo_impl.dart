import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/domain/entity/user_entity.dart';

import '../../domain/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo{
  final FirebaseAuth _firebaseAuth =FirebaseAuth.instance;
  final FirebaseFirestore _firestore;

  AuthRepoImpl(this._firestore);

  @override
  Future<UserEntity?> createUserWithEmailAndPassword(String name,
      String email,String password) async{
    try{
      UserCredential userCredential=await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      if(userCredential.user!= null) {
        UserEntity user = UserEntity(
            uid: userCredential.user!.uid,
            name: name,
            email: email);
        return user;
      }
    }catch(e){
      debugPrint("$e");
    }
    return null;
  }

  @override
  Future<UserEntity?> loginWithEmailAndPassword(String email,String password) async{
    try{
      UserCredential userCredential=await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    }catch(e) {
      debugPrint("$e");
    }
    return null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
   try{
        User? user=_firebaseAuth.currentUser;
        if(user!=null){
          return UserEntity(
              uid: user.uid,
              name: user.displayName ?? '',
              email: user.email ??'');
        }
   }catch(e){
     debugPrint("$e");
   }
   return null;
  }

  @override
  Future<void> logOut() async{
   await _firebaseAuth.signOut();
  }

  @override
  Future<List<UserEntity>> fetchAllUsers()async {
    try{
   final querySnapshot=await _firestore.collection('users').get();
   return querySnapshot.docs.map((doc) => UserEntity.fromJson(doc.data())).toList();
    }catch(e){
  throw Exception("Failed to Fetch UUsers");
    }
  }

}