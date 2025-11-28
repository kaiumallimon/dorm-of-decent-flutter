import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class CustomPageHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final Widget? actionButton;

  const CustomPageHeader({super.key, required this.theme, required this.title, this.actionButton});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}
