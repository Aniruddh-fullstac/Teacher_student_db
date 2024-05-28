import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Define events
abstract class HomeEvent {}

class AddStudentEvent extends HomeEvent {
  final String name;
  final DateTime dateOfBirth;
  final String gender;

  AddStudentEvent({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
  });
}

// Define states
abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {}

class HomeErrorState extends HomeState {
  final String errorMessage;

  HomeErrorState(this.errorMessage);
}

// Define BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore firestore;

  HomeBloc({required this.firestore}) : super(HomeInitialState()) {
    on<AddStudentEvent>((event, emit) async {
      emit(HomeLoadingState());
      try {
        await firestore.collection('students').add({
          'name': event.name,
          'dateOfBirth': event.dateOfBirth,
          'gender': event.gender,
        });
        emit(HomeSuccessState());
      } catch (error) {
        emit(HomeErrorState('Failed to upload data. Please try again later.'));
      }
    });
  }
}
