import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/ui/widgets/wrapper_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldState> wrapperScaffoldKey = GlobalKey<ScaffoldState>();

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
    if (location.startsWith(AppRoutes.bills)) return 3;

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
        context.go(AppRoutes.bills);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final currentIndex = _getCurrentIndex(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      key: wrapperScaffoldKey,
      drawer: WrapperDrawer(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(child: widget.child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withAlpha(20)
            )
          )
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: _onDestinationSelected,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primary.withAlpha(50),
          elevation: 3,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
              icon: Icon(Icons.request_quote_outlined),
              selectedIcon: Icon(
                Icons.request_quote,
                color: theme.colorScheme.primary,
              ),
              label: 'Bills',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.account_circle_outlined),
            //   selectedIcon: Icon(
            //     Icons.account_circle,
            //     color: theme.colorScheme.primary,
            //   ),
            //   label: 'Account',
            // ),
          ],
        ),
      ),
    );
  }
}
