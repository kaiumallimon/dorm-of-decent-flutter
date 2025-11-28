import 'package:flutter/material.dart';

class CustomPageHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;

  const CustomPageHeader({super.key, required this.theme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
