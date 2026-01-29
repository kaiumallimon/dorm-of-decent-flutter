import 'package:dorm_of_decents/configs/assets.dart';
import 'package:flutter/material.dart';

class WrapperDrawer extends StatelessWidget {
  const WrapperDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.sizeOf(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: windowSize.height * 0.10,
              bottom: windowSize.height * 0.065,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.colorScheme.onSurface.withAlpha(25))),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(25),
              ),
              child: Image.asset(
                AppAssets.appLogo,
                width: windowSize.width * 0.2,
                height: windowSize.width * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
