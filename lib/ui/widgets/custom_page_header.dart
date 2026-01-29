import 'package:flutter/material.dart';

class CustomPageHeader extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final Widget? actionButton;
  final String? subtitle;
  final bool showBackButton;

  const CustomPageHeader({
    super.key,
    required this.theme,
    required this.title,
    this.actionButton,
    this.subtitle,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.onSurface.withAlpha(20)),
        ),
      ),
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
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Crimson Text',
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Crimson Text',
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
              ],
            ),
          ),
          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}
