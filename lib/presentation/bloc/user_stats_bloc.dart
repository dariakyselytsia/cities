import 'package:flutter_bloc/flutter_bloc.dart';

/// Events for UserStatsBloc
abstract class UserStatsEvent {}

/// States for UserStatsBloc
abstract class UserStatsState {}

/// BLoC for managing user statistics updates and recalculation.
class UserStatsBloc extends Bloc<UserStatsEvent, UserStatsState> {
  UserStatsBloc() : super(UserStatsInitial());
}

class UserStatsInitial extends UserStatsState {}
