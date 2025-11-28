import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final double borderRadius;
  final bool isBordered;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    this.width = double.infinity,
    this.height = 52,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.borderRadius = 6,
    this.isBordered = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SizedBox(
            height: height,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Enter your ${label.toLowerCase()}",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, color: theme.colorScheme.primary)
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                filled: !isBordered,
                fillColor: theme.colorScheme.primary.withAlpha(25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: isBordered
                      ? BorderSide(
                          color: theme.colorScheme.outline.withAlpha(25),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: isBordered
                      ? BorderSide(
                          color: theme.colorScheme.outline.withAlpha(25),
                        )
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
