import 'package:flutter_bloc/flutter_bloc.dart';

/// Events for UserProfileBloc
abstract class UserProfileEvent {}

/// States for UserProfileBloc
abstract class UserProfileState {}

/// BLoC for managing user profile state and preferences.
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial());
}

class UserProfileInitial extends UserProfileState {}
