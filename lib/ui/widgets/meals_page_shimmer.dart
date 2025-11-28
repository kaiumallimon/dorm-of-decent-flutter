import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MealsPageShimmer extends StatelessWidget {
  const MealsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Meals Card Shimmer
          _buildShimmerContainer(
            theme: theme,
            isDark: isDark,
            width: double.infinity,
            height: 140,
          ),
          const SizedBox(height: 32),

          // Section Title Shimmer
          _buildShimmerContainer(
            theme: theme,
            isDark: isDark,
            width: 200,
            height: 20,
          ),
          const SizedBox(height: 16),

          // Member Cards Grid Shimmer
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(4, (index) {
              return _buildShimmerContainer(
                theme: theme,
                isDark: isDark,
                width: (MediaQuery.of(context).size.width - 60) / 2,
                height: 140,
              );
            }),
          ),

          const SizedBox(height: 32),

          // Filters Shimmer
          Row(
            children: [
              Expanded(
                child: _buildShimmerContainer(
                  theme: theme,
                  isDark: isDark,
                  width: double.infinity,
                  height: 70,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShimmerContainer(
                  theme: theme,
                  isDark: isDark,
                  width: double.infinity,
                  height: 70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Shimmer
          _buildTableShimmer(theme: theme, isDark: isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer({
    required ThemeData theme,
    required bool isDark,
    required double width,
    required double height,
  }) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(10)
          : theme.colorScheme.outline.withAlpha(25),
      highlightColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(50)
          : theme.colorScheme.outline.withAlpha(10),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTableShimmer({required ThemeData theme, required bool isDark}) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(10)
          : theme.colorScheme.outline.withAlpha(25),
      highlightColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(50)
          : theme.colorScheme.outline.withAlpha(10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(25)),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(25),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            ...List.generate(6, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
