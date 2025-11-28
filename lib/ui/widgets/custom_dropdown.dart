import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double borderRadius;
  final bool isBordered;
  final IconData? prefixIcon;
  final String? hint;

  const CustomDropdown({
    super.key,
    this.width = double.infinity,
    this.height = 52,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.borderRadius = 6,
    this.isBordered = true,
    this.prefixIcon,
    this.hint,
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
          Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isBordered
                  ? theme.colorScheme.surface
                  : theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(borderRadius),
              border: isBordered
                  ? Border.all(
                      color: theme.colorScheme.outline.withAlpha(25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      hint: hint != null
                          ? Text(
                              hint!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  100,
                                ),
                              ),
                            )
                          : null,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      style: theme.textTheme.bodyMedium,
                      dropdownColor: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(borderRadius),
                      items: items,

                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
