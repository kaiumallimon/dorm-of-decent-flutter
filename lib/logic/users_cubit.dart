import 'package:dorm_of_decents/data/models/profile.dart';
import 'package:dorm_of_decents/data/services/api/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  final List<Profile> users;

  const UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UsersError extends UsersState {
  final String message;

  const UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersEmpty extends UsersState {
  const UsersEmpty();
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(const UsersInitial());

  final UsersApi _usersApi = UsersApi();

  Future<void> fetchUsers() async {
    emit(const UsersLoading());
    try {
      final users = await _usersApi.fetchUsers();
      if (users.isEmpty) {
        emit(const UsersEmpty());
      } else {
        emit(UsersLoaded(users: users));
      }
    } catch (e) {
      emit(UsersError(message: e.toString()));
    }
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _usersApi.updateUserRole(userId, role);
      // Refresh the users list after updating
      await fetchUsers();
    } catch (e) {
      emit(UsersError(message: e.toString()));
    }
  }
}
