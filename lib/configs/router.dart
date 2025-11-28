import 'dart:async';

import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/pages/dashboard_wrapper.dart';
import 'package:dorm_of_decents/ui/pages/login_page.dart';
import 'package:dorm_of_decents/ui/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isDashboard = state.matchedLocation == AppRoutes.dashboard;

      // Skip redirect logic during splash
      if (isSplash) {
        return null;
      }

      // If authenticated and trying to access login, redirect to dashboard
      if (isAuthenticated && isLogin) {
        return AppRoutes.dashboard;
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && isDashboard) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      // initial: Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardWrapper(),
      ),
    ],
  );
}

/// Helper class to refresh GoRouter when stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
