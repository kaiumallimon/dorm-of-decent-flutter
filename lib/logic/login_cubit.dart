import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/data/services/auth/supabase_auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginLoading extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  LoginSuccess({required this.loginResponse});

  @override
  List<Object?> get props => [loginResponse];
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// Login cubit
class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial()) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  Future<void> login({required String email, required String password}) async {
    // emit loading state
    emit(LoginLoading());

    try {
      // Use Supabase authentication
      final authService = SupabaseAuthService();
      final response = await authService.login(
        email: email,
        password: password,
      );

      // Clear controllers on successful login
      emailController.clear();
      passwordController.clear();

      // emit success state
      emit(LoginSuccess(loginResponse: response));
    } catch (e) {
      // emit failure state
      emit(LoginFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    // dispose controllers automatically
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
