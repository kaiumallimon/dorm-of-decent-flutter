import 'dart:async';

import 'package:animations/animations.dart';
import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/pages/account_page.dart';
import 'package:dorm_of_decents/ui/pages/dashboard_page.dart';
import 'package:dorm_of_decents/ui/pages/dashboard_wrapper.dart';
import 'package:dorm_of_decents/ui/pages/expenses_page.dart';
import 'package:dorm_of_decents/ui/pages/login_page.dart';
import 'package:dorm_of_decents/ui/pages/logs_page.dart';
import 'package:dorm_of_decents/ui/pages/meals_page.dart';
import 'package:dorm_of_decents/ui/pages/settlements_page.dart';
import 'package:dorm_of_decents/ui/pages/splash_page.dart';
import 'package:dorm_of_decents/ui/pages/users_page.dart';
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
      final isDashboardRoute = state.matchedLocation.startsWith('/dashboard');

      // Skip redirect logic during splash
      if (isSplash) {
        return null;
      }

      // If authenticated and trying to access login, redirect to dashboard home
      if (isAuthenticated && isLogin) {
        return AppRoutes.home;
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && isDashboardRoute) {
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

      // Dashboard with nested routes
      ShellRoute(
        builder: (context, state, child) {
          return DashboardWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.meals,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MealsPage()),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExpensesPage()),
          ),
          GoRoute(
            path: AppRoutes.settlements,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettlementsPage()),
          ),
          GoRoute(
            path: AppRoutes.account,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AccountPage()),
          ),

          // Additional routes
          GoRoute(
            path: AppRoutes.logs,
            pageBuilder: (context, state) =>
                material3TransitionPage(child: const LogsPage()),
          ),
          GoRoute(
            path: AppRoutes.users,
            pageBuilder: (context, state) =>
                material3TransitionPage(child: const UsersPage()),
          ),
        ],
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

CustomTransitionPage<T> material3TransitionPage<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
  SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
}) {
  return CustomTransitionPage<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}
