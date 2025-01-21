import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flutter_chat_app/features/auth/presentation/cubits/auth-cubit/auth_state.dart';

import '../../../domain/entity/user_entity.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  UserEntity? userEntity;

  AuthCubit({required this.authRepo}) : super(AuthInitialState());

  // Login
  Future<void> login(String email, String password) async {
    emit(LoadingState());
    try {
      final user = await authRepo.loginWithEmailAndPassword(email, password);
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(FailureState('Login Failed'));
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Register
  Future<void> register(String name, String email, String password) async {
    emit(LoadingState());
    try {
      final user = await authRepo.createUserWithEmailAndPassword(name, email, password);
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(FailureState('Register Failed'));
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Logout
  Future<void> logOut() async {
    emit(LoadingState());
    try {
      await authRepo.logOut();
      emit(AuthInitialState());
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Check Current User
  Future<void> checkCurrentUser() async {
    emit(LoadingState());
    try {
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(AuthInitialState());
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Fetch Users Excluding Current User
  Future<void> fetchUsersExcluding() async {
    try {
      final users = await authRepo.fetchAllUsers();
      final currentUser = await authRepo.getCurrentUser();
      final filteredUsers = users.where((user) => user.uid != currentUser?.uid).toList();
      emit(UsersFetchedState(filteredUsers));
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }
}



/*
class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  UserEntity? userEntity;
  AuthCubit({required this.authRepo}) : super(AuthInitialState());

  //login
  Future<void> login(String email,String password) async{
    emit(LoadingState());
    try{
      final user=await authRepo.loginWithEmailAndPassword(email, password);
      if(user!=null){
        emit(AuthenticatedState(user));
      }
      else{
        emit(FailureState('Login Failed'));
      }
    }catch(e){
      emit(FailureState(e.toString()));
    }
  }
  
  //register
  Future<void> register(String name, String email, String password) async{
    emit(LoadingState());
    try{
      final user=await authRepo.createUserWithEmailAndPassword(name, email, password);
      if(user!=null){
          emit(AuthenticatedState(user));
      }
      else{
        emit(FailureState('Register Failed'));
      }
    }catch(e){
      emit(FailureState(e.toString()));
    }
  }

  //logout
  Future<void> logOut() async{
   emit(LoadingState());
   try {
     await authRepo.logOut();
     emit(AuthInitialState());
   }catch(e){
     emit(FailureState(e.toString()));
   }
   }

   // Check Current User
  Future<void> checkCurrentUser() async{
    emit(LoadingState());
    final user=await authRepo.getCurrentUser();
    try {
      if (user != null) {
        emit(AuthenticatedState(user));
      }
      else {
        emit(AuthInitialState());
      }
    }catch(e) {
         emit(FailureState(e.toString()));
       }
  }

  //fetchUsers Excluding currentUser
  Future<void> fetchUsersExcluding() async{
   final users=await authRepo.fetchAllUsers();
   final currentUser=await authRepo.getCurrentUser();
   final filteredUsers= users.where((user) => user.uid!=currentUser?.uid).toList();
   emit(UsersFetchedState(filteredUsers));
  }

}*/
