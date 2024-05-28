// teacher_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object> get props => [];
}

class FetchStudents extends TeacherEvent {}

class UpdateStudent extends TeacherEvent {
  final String studentId;
  final Map<String, dynamic> updatedData;

  const UpdateStudent({required this.studentId, required this.updatedData});

  @override
  List<Object> get props => [studentId, updatedData];
}

// States
abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<DocumentSnapshot> students;

  const TeacherLoaded({required this.students});

  @override
  List<Object> get props => [students];
}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final FirebaseFirestore firestore;

  TeacherBloc({required this.firestore}) : super(TeacherInitial()) {
    on<FetchStudents>(_onFetchStudents);
    on<UpdateStudent>(_onUpdateStudent);
  }

  Future<void> _onFetchStudents(
      FetchStudents event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    try {
      final QuerySnapshot snapshot =
          await firestore.collection('students').get();
      final students = snapshot.docs;

      // Debugging print statement
      print('Fetched students: ${students.map((doc) => doc.data()).toList()}');

      emit(TeacherLoaded(students: students));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStudent(
      UpdateStudent event, Emitter<TeacherState> emit) async {
    try {
      await firestore
          .collection('students')
          .doc(event.studentId)
          .update(event.updatedData);
      add(FetchStudents()); // Refresh the data after update
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }
}
