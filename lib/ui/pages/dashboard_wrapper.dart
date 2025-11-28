import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardWrapper extends StatefulWidget {
  final Widget child;

  const DashboardWrapper({super.key, required this.child});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.meals)) return 1;
    if (location.startsWith(AppRoutes.expenses)) return 2;
    if (location.startsWith(AppRoutes.settlements)) return 3;
    if (location.startsWith(AppRoutes.account)) return 4;

    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.meals);
        break;
      case 2:
        context.go(AppRoutes.expenses);
        break;
      case 3:
        context.go(AppRoutes.settlements);
        break;
      case 4:
        context.go(AppRoutes.account);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
        elevation: 3,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(
              Icons.restaurant,
              color: theme.colorScheme.primary,
            ),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(
              Icons.payments,
              color: theme.colorScheme.primary,
            ),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: theme.colorScheme.primary,
            ),
            label: 'Settlements',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(
              Icons.account_circle,
              color: theme.colorScheme.primary,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
