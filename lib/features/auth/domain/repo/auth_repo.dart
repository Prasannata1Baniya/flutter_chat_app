/*
   -chat app
   -loginWithEmailAndPassword
   -register
   -logOut
   -getCurrentUser

 */

import '../entity/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity?> loginWithEmailAndPassword(String email,String password);
  Future<UserEntity?> createUserWithEmailAndPassword(String name, String email,String password);
  Future<UserEntity?> getCurrentUser();
  Future<void> logOut();
  Future<List<UserEntity>> fetchAllUsers();
}