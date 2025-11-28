import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/settlement_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettlementsPage extends StatelessWidget {
  const SettlementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPageHeader(theme: theme, title: 'Settlements'),
            Expanded(
              child: BlocConsumer<SettlementCubit, SettlementState>(
                listener: (context, state) {
                  // Handle side effects if needed
                },
                builder: (context, state) {
                  if (state is SettlementInitial) {
                    context.read<SettlementCubit>().fetchSettlementData();
                    return const MealsPageShimmer();
                  } else if (state is SettlementLoading) {
                    return const MealsPageShimmer();
                  } else if (state is SettlementError) {
                    return Center(child: Text(state.message));
                  } else if (state is SettlementEmpty) {
                    return Center(child: Text(state.message));
                  } else if (state is SettlementLoaded) {
                    final settlementResponse = state.settlementResponse;
                    final settlements = state.settlements;

                    // Calculate totals
                    final totalExpenses = settlementResponse.expenses
                        .fold<double>(0.0, (sum, e) => sum + e.amount);
                    final totalMeals = settlementResponse.meals.fold<double>(
                      0.0,
                      (sum, m) => sum + m.mealCount,
                    );
                    final mealRate = totalMeals > 0
                        ? totalExpenses / totalMeals
                        : 0.0;
                    final activeMembers = settlementResponse.profiles.length;

                    // Sort settlements by balance (those who owe first)
                    final sortedSettlements = settlements.entries.toList()
                      ..sort(
                        (a, b) => (a.value['balance'] as double).compareTo(
                          b.value['balance'] as double,
                        ),
                      );

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<SettlementCubit>()
                            .refreshSettlementData();
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards - One per row
                            _buildSummaryCard(
                              context,
                              theme,
                              'Total Expenses',
                              'BDT ${totalExpenses.toStringAsFixed(2)}',
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryCard(
                              context,
                              theme,
                              'Total Meals',
                              totalMeals.toStringAsFixed(1),
                              null,
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryCard(
                              context,
                              theme,
                              'Meal Rate',
                              'BDT ${mealRate.toStringAsFixed(2)}',
                              'per meal',
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryCard(
                              context,
                              theme,
                              'Active Members',
                              activeMembers.toString(),
                              null,
                            ),
                            const SizedBox(height: 32),

                            // Individual Settlements Section
                            Text(
                              'Individual Settlements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Settlement Cards - One per row
                            ...sortedSettlements.expand((entry) {
                              final settlement = entry.value;
                              final name = settlement['name'] as String;
                              final balance = settlement['balance'] as double;
                              final mealsConsumed =
                                  settlement['meals_consumed'] as double;
                              final mealCost =
                                  settlement['owed_amount'] as double;
                              final paid =
                                  settlement['expenses_paid'] as double;
                              final paymentProgress = paid > 0
                                  ? ((paid / mealCost) * 100).clamp(0.0, 200.0)
                                  : 0.0;

                              final isOwing = balance < 0;

                              return [
                                _buildSettlementCard(
                                  context,
                                  theme,
                                  name,
                                  balance,
                                  mealsConsumed,
                                  mealCost,
                                  paid,
                                  paymentProgress,
                                  isOwing,
                                ),
                                const SizedBox(height: 12),
                              ];
                            }),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('Unknown state'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    dynamic trailing,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing is String) ...[
            const SizedBox(height: 4),
            Text(
              trailing,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementCard(
    BuildContext context,
    ThemeData theme,
    String name,
    double balance,
    double meals,
    double mealCost,
    double paid,
    double paymentProgress,
    bool isOwing,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOwing
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOwing ? 'Owes' : 'Gets Back',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOwing ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'BDT ${balance.abs().toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOwing ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOwing ? 'Amount to pay' : 'Amount to receive',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(theme, 'Meals', meals.toStringAsFixed(1)),
          const SizedBox(height: 8),
          _buildDetailRow(
            theme,
            'Meal Cost',
            'BDT ${mealCost.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(theme, 'Paid', 'BDT ${paid.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          // Payment Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${paymentProgress.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: paymentProgress / 100,
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    paymentProgress >= 100
                        ? Colors.blue
                        : theme.colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
