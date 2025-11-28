import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String name;

  const ProfileInfoSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Column(
      children: [
        Text(
          name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
