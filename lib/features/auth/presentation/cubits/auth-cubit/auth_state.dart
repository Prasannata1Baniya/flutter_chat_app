import 'package:flutter_chat_app/features/auth/domain/entity/user_entity.dart';

abstract class AuthState{}

class AuthInitialState extends AuthState{}

class LoadingState extends AuthState{}

class AuthenticatedState extends AuthState{
  final UserEntity? user;
  AuthenticatedState(this.user);
}
class UnAuthenticatedState extends AuthState{}

class FailureState extends AuthState{
  final String error;
  FailureState(this.error);
}

class UsersFetchedState extends AuthState{
  final List<UserEntity> users;
  UsersFetchedState(this.users);
}

class NoUsersFoundState extends AuthState {}
class NoCurrentUserState extends AuthState{}
