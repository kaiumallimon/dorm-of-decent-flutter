import 'package:flutter/material.dart';

class CustomPageHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final Widget? actionButton;
  final bool showBackButton;

  const CustomPageHeader({
    super.key,
    required this.theme,
    required this.title,
    this.actionButton,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}
