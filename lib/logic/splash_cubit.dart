import 'package:flutter_bloc/flutter_bloc.dart';

// splash states
abstract class SplashState {}
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashFinished extends SplashState {
  final bool isLoggedIn;

  SplashFinished(this.isLoggedIn);
}

// Splash Cubit
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> startSplash() async {
    // emit the loading state
    emit(SplashLoading());

    // simulated loading time
    await Future.delayed(Duration(seconds: 2));

    // check if the user is logged in
    // mock: false
    final bool isLoggedIn = false;

    // emit the finished state
    emit(SplashFinished(isLoggedIn));
  }
}
