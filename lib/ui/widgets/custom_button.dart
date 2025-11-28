import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { solid, outline, ghost, secondary, destructive }

enum ButtonSize { sm, md, lg }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final String? loadingLabel;
  final double borderRadius;
  final IconData? icon;

  // Optional custom overrides
  final Color? customBg;
  final Color? customFg;
  final Color? customBorder;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.loadingLabel,
    this.onPressed,
    this.variant = ButtonVariant.solid,
    this.size = ButtonSize.md,
    this.loading = false,
    this.borderRadius = 6,

    this.customBg,
    this.customFg,
    this.customBorder,
  });

  EdgeInsets _padding() {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  TextStyle _textStyle(ThemeData theme) {
    switch (size) {
      case ButtonSize.sm:
        return theme.textTheme.bodyMedium!;
      case ButtonSize.md:
        return theme.textTheme.bodyLarge!;
      case ButtonSize.lg:
        return theme.textTheme.titleMedium!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    // base colors
    final primary = theme.colorScheme.primary;
    final destructive = theme.colorScheme.error;
    final fgOnPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    final outline = theme.colorScheme.outline.withAlpha(50);

    // derive colors based on variant (can be overridden)
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case ButtonVariant.solid:
        bg = primary;
        fg = fgOnPrimary;
        border = Colors.transparent;
        break;

      case ButtonVariant.secondary:
        bg = theme.colorScheme.secondaryContainer;
        fg = theme.colorScheme.onSecondaryContainer;
        border = Colors.transparent;
        break;

      case ButtonVariant.destructive:
        bg = destructive;
        fg = theme.colorScheme.onError;
        border = Colors.transparent;
        break;

      case ButtonVariant.outline:
        bg = surface;
        fg = theme.colorScheme.onSurface;
        border = outline;
        break;

      case ButtonVariant.ghost:
        bg = Colors.transparent;
        fg = theme.colorScheme.onSurface;
        border = Colors.transparent;
        break;
    }

    // apply overrides
    bg = customBg ?? bg;
    fg = customFg ?? fg;
    border = customBorder ?? border;

    final disabled = onPressed == null || loading;

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: _padding(),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: border,
              width: border == Colors.transparent ? 0 : 1,
            ),
          ),
          child: Center(
            child: loading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: _textStyle(theme).fontSize!,
                        height: _textStyle(theme).fontSize!,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        loadingLabel ??
                            label, // Show the original label instead of "Loading..." for consistency
                        style: _textStyle(theme).copyWith(color: fg),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: .center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: fg, size: _textStyle(theme).fontSize),
                        SizedBox(width: 8),
                      ],
                      Text(label, style: _textStyle(theme).copyWith(color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
