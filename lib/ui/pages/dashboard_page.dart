import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/dashboard_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:dorm_of_decents/utils/datetime_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<DashboardCubit, DashboardState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is DashboardInitial) {
              context.read<DashboardCubit>().fetchDashboardData();
              return const MealsPageShimmer();
            } else if (state is DashboardLoading) {
              return const MealsPageShimmer();
            } else if (state is DashboardError) {
              return Center(child: Text(state.message));
            } else if (state is DashboardEmpty) {
              return Center(child: Text(state.message));
            } else if (state is DashboardLoaded) {
              final data = state.dashboardResponse;
              final userName = state.userName;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<DashboardCubit>().refreshDashboardData();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          final isCollapsed =
                              constraints.maxHeight <=
                              kToolbarHeight +
                                  MediaQuery.of(context).padding.top;
                          return FlexibleSpaceBar(
                            titlePadding: EdgeInsets.zero,
                            title: isCollapsed
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      'Overview',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  )
                                : null,
                            background: Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Welcome back, ${userName.isNotEmpty ? userName : 'Guest'}!',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "It's ${DatetimeUtil.getFormattedDateToday()}",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Meal Rate Card
                          _buildMetricCard(
                            context,
                            theme,
                            'Meal Rate',
                            'BDT ${data.mealRate.toStringAsFixed(2)}',
                            'Per meal cost',
                            Icons.restaurant,
                          ),
                          const SizedBox(height: 12),

                          // Total Meals Card
                          _buildMetricCard(
                            context,
                            theme,
                            'Total Meals',
                            data.totalMeals.toStringAsFixed(1),
                            '${data.dailyExpenseAverage.toStringAsFixed(1)} meals/day',
                            Icons.dinner_dining,
                          ),
                          const SizedBox(height: 12),

                          // Total Expenses Card
                          _buildMetricCard(
                            context,
                            theme,
                            'Total Expenses',
                            'BDT ${data.totalExpenses.toStringAsFixed(2)}',
                            'BDT ${data.dailyExpenseAverage.toStringAsFixed(2)}/day',
                            Icons.attach_money,
                          ),
                          const SizedBox(height: 12),

                          // Weekly Trend Card
                          _buildMetricCard(
                            context,
                            theme,
                            'Weekly Trend',
                            '${data.weeklyTrend.toStringAsFixed(1)}%',
                            'Last 7 days vs previous',
                            data.weeklyTrend >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            valueColor: data.weeklyTrend >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(height: 12),

                          // Days Active Card
                          _buildMetricCard(
                            context,
                            theme,
                            'Days Active',
                            data.daysActive.toString(),
                            '${data.memberCount} active members',
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 12),

                          // Avg per Person Card
                          _buildSmallMetricCard(
                            context,
                            theme,
                            'Avg per Person',
                            data.avgMealsPerPerson.toStringAsFixed(1),
                            'Meals per member',
                            Icons.person,
                          ),
                          const SizedBox(height: 12),

                          // Food Budget Card
                          _buildSmallMetricCard(
                            context,
                            theme,
                            'Food Budget',
                            '${((data.totalExpenses / data.totalExpenses) * 100).toStringAsFixed(1)}%',
                            'BDT ${data.totalExpenses.toStringAsFixed(2)} of total',
                            Icons.pie_chart,
                          ),
                          const SizedBox(height: 12),

                          // Total Transactions Card
                          _buildSmallMetricCard(
                            context,
                            theme,
                            'Total Transactions',
                            data.totalTransactions.toString(),
                            '${data.expensesPerDay.toStringAsFixed(1)} expenses/day',
                            Icons.receipt,
                          ),
                          const SizedBox(height: 12),

                          // Projected Total Card
                          _buildSmallMetricCard(
                            context,
                            theme,
                            'Projected Total',
                            'BDT ${(data.projectedTotal / 1000).toStringAsFixed(1)}K',
                            '30-day projection',
                            Icons.trending_up,
                          ),
                          const SizedBox(height: 24),

                          // Expense Breakdown Section
                          _buildSectionHeader(
                            theme,
                            'Expense Breakdown by Category',
                          ),
                          const SizedBox(height: 12),
                          _buildExpenseBreakdownChart(context, theme, data),
                          const SizedBox(height: 24),

                          // Category Distribution
                          _buildSectionHeader(theme, 'Category Distribution'),
                          const SizedBox(height: 12),
                          _buildCategoryDistribution(context, theme, data),
                          const SizedBox(height: 24),

                          // Top Meal Consumers
                          _buildTopMealConsumers(context, theme, data),
                          const SizedBox(height: 12),

                          // Top Contributors
                          _buildTopContributors(context, theme, data),
                          const SizedBox(height: 24),

                          // Recent Expenses
                          _buildSectionHeader(theme, 'Recent Expenses'),
                          const SizedBox(height: 4),
                          Text(
                            'Latest transactions from all members',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRecentExpenses(context, theme, data),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    String subtitle,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExpenseBreakdownChart(
    BuildContext context,
    ThemeData theme,
    data,
  ) {
    final categories = data.expensesByCategory;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      'No expense data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Simple bar chart representation
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: categories.entries.map<Widget>((entry) {
                            final percentage =
                                (entry.value / data.totalExpenses) * 100;
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'BDT ${(entry.value / 1000).toStringAsFixed(1)}K',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: (percentage / 100) * 200,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.key.isEmpty
                                        ? ''
                                        : '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(
    BuildContext context,
    ThemeData theme,
    data,
  ) {
    final categories = data.expensesByCategory;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: categories.entries.map<Widget>((entry) {
          final percentage = (entry.value / data.totalExpenses) * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.isEmpty
                          ? ''
                          : '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'BDT ${entry.value.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopMealConsumers(BuildContext context, ThemeData theme, data) {
    final topConsumers = data.topMealConsumers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Meal Consumers',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Members who ate the most meals this month',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ...topConsumers.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final consumer = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consumer.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${consumer.totalMeals.toStringAsFixed(0)} meals • ${consumer.percentage.toStringAsFixed(1)}% of total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'BDT ${consumer.cost.toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: consumer.percentage / 100,
                      backgroundColor: theme.colorScheme.outline.withOpacity(
                        0.1,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopContributors(BuildContext context, ThemeData theme, data) {
    final topContributors = data.topContributors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Contributors',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Members who paid the most expenses',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ...topContributors.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final contributor = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contributor.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${contributor.transactionCount} transactions • ${contributor.percentage.toStringAsFixed(1)}% of total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'BDT ${contributor.totalAmount.toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: contributor.percentage / 100,
                      backgroundColor: theme.colorScheme.outline.withOpacity(
                        0.1,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(BuildContext context, ThemeData theme, data) {
    final recentExpenses = data.recentExpenses;

    return Column(
      children: recentExpenses.map<Widget>((expense) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.profiles.name} • ${expense.date}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'BDT ${expense.amount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
