import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flutter_chat_app/features/auth/presentation/cubits/auth-cubit/auth_state.dart';
import '../../../domain/entity/user_entity.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  UserEntity? _currentUser;
  AuthCubit({required this.authRepo}) : super(AuthInitialState());

  // Login
  Future<void> login(String email, String password) async {
    emit(LoadingState());
    try {
      final user = await authRepo.loginWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(AuthenticatedState(user));
      } else {
        emit(FailureState('Login failed'));
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Register
  Future<void> register(String name, String email, String password) async {
    emit(LoadingState());
    try {
      final user = await authRepo.createUserWithEmailAndPassword(
        name, email, password,
      );
      if (user != null) {
        _currentUser = user;
        emit(AuthenticatedState(user));
      } else {
        emit(FailureState('Register failed'));
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
      _currentUser = null;
      emit(UnAuthenticatedState());
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
        _currentUser = user;
        emit(AuthenticatedState(user));
      } else {
        _currentUser = null;
        emit(UnAuthenticatedState());
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

  // Public getter for currentUser
  UserEntity? get currentUser => _currentUser;

  // Fetch users excluding current user
  Future<void> fetchUsersExcluding() async {
    emit(LoadingState());
    try {
      final currentUser = await authRepo.getCurrentUser();
      if (currentUser == null) {
        emit(NoCurrentUserState());
        return;
      }

      final users = await authRepo.fetchAllUsers();
      final filteredUsers =
      users.where((u) => u.uid != currentUser.uid).toList();

      if (filteredUsers.isEmpty) {
        emit(NoUsersFoundState());
      } else {
        emit(UsersFetchedState(filteredUsers));
      }
    } catch (e) {
      emit(FailureState("Error fetching users: $e"));
    }
  }

   // To update or edit
  Future<void> updateName(String newName) async {
    try {
      final uid = _currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': newName,
        });

        _currentUser = _currentUser?.copyWith(name: newName);

        emit(AuthenticatedState(_currentUser!));

        await fetchUsersExcluding();
      }
    } catch (e) {
      emit(FailureState(e.toString()));
    }
  }

}
